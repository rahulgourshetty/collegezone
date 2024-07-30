import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../models/chat_user.dart';
import '../models/message.dart';
import '../models/group.dart';
import 'notification_access_token.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static late ChatUser me;

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name,
          "body": msg,
          "android_channel_id": "chats"
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAQ0Bf7ZA:APA91bGd5IN5v43yedFDo86WiSuyTERjmlr4tyekbw_YW6_pTq6jumZYvqzWQCiGdopxpkvGtE2aqcdtTf2nNXqoYkFqz5KSxauka1rKEnEwLrPQ8pF-Mpb5nTtHJBi6nsWpe9CnIgH-'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding a chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using CollegeZone!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  ///************** Group Chat Related APIs **************
    static Future<ChatUser?> getUserById(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return ChatUser.fromJson(userDoc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  // Create a new group
static Future<String?> uploadGroupImage(File imageFile) async {
    try {
      String filePath = 'group_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference reference = _storage.ref().child(filePath);
      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  static Future<bool> createGroup(Group group, File? imageFile) async {
    try {
      // Check if user is authenticated
      if (APIs.user == null) {
        throw Exception('No user is currently signed in.');
      }

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadGroupImage(imageFile);
      }

      final groupRef = _firestore.collection('groups').doc();
      group.id = groupRef.id; // Assign the auto-generated ID to the group
      group.image = imageUrl; // Assign the image URL to the group if available
      await groupRef.set(group.toJson());

      // Add group to creator's groups collection
      await _firestore
          .collection('users')
          .doc(APIs.user!.uid)
          .collection('my_groups')
          .doc(group.id)
          .set({});

      return true;
    } catch (e) {
      log('Error creating group: $e');
      return false;
    }
  }



  // Join a group
  static Future<bool> joinGroup(String groupId) async {
    try {
      await firestore.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([user.uid])
      });
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_groups')
          .doc(groupId)
          .set({});
      return true;
    } catch (e) {
      log('Error joining group: $e');
      return false;
    }
  }

  // Leave a group
  static Future<bool> leaveGroup(String groupId) async {
    try {
      await firestore.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([user.uid]),
      });
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_groups')
          .doc(groupId)
          .delete();
      return true;
    } catch (e) {
      log('Error leaving group: $e');
      return false;
    }
  }

  // Get user's groups
  static Stream<List<Group>> getMyGroups() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_groups')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Group> groups = [];
      for (var doc in snapshot.docs) {
        final groupDoc = await firestore.collection('groups').doc(doc.id).get();
        if (groupDoc.exists) {
          groups.add(Group.fromJson(groupDoc.data()!));
        }
      }
      return groups;
    });
  }

  // Search for groups
  static Future<QuerySnapshot<Map<String, dynamic>>> searchGroups(
      String query) async {
    return firestore
        .collection('groups')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
  }

  // Get group messages
  static Stream<List<Message>> getGroupMessages(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('sent', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList());
  }

  // Send message to group
  static Future<bool> sendMessageToGroup(
      String groupId, String msg, Type type) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      final message = Message(
        toId: groupId,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time,
      );

      await firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(time)
          .set(message.toJson());

      // Update the group's last message
      await firestore.collection('groups').doc(groupId).update({
        'lastMessage': msg,
        'lastMessageTime': time,
      });

      return true;
    } catch (e) {
      log('Error sending message to group: $e');
      return false;
    }
  }
  static Future<QuerySnapshot> getAllGroups() async {
    try {
      // Fetch all documents from the 'groups' collection
      QuerySnapshot snapshot = await _firestore.collection('groups').get();
      return snapshot;
    } catch (e) {
      print('Error fetching groups: $e');
      rethrow;
    }
  }

  // Method to search groups by name
  
  static Future<List<ChatUser>> getGroupMembers(String groupId) async {
  try {
    final groupDoc = await firestore.collection('groups').doc(groupId).get();
    final memberIds = List<String>.from(groupDoc.data()?['memberIds'] ?? []);

    final membersSnapshot = await firestore.collection('users').where('id', whereIn: memberIds).get();

    return membersSnapshot.docs.map((doc) => ChatUser.fromJson(doc.data())).toList();
  } catch (e) {
    print('Error getting group members: $e');
    return [];
  }
}
static Future<bool> updateGroupInfo(String groupId, Map<String, dynamic> updates) async {
  try {
    await firestore.collection('groups').doc(groupId).update(updates);
    return true;
  } catch (e) {
    print('Error updating group info: $e');
    return false;
  }
  // In APIs class
 Future<ChatUser?> getUserById(String userId) async {
  try {
    final userDoc = await firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return ChatUser.fromJson(userDoc.data()!);
    } else {
      return null; // Or handle the case where user doesn't exist
    }
  } catch (e) {
    print('Error getting user: $e');
    return null; // Or handle the error case
  }
}

}
}


 