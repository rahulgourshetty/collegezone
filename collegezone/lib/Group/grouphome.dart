import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/Group/group_info_screen.dart';
import 'package:we_chat/Group/search_group_screen.dart';
import 'package:we_chat/Group/group_chat_screen.dart';
import 'package:we_chat/models/group.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateGroupDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchGroupDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<List<Group>>(
          stream: APIs.getMyGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No groups found', style: TextStyle(color: Colors.white)));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final group = snapshot.data![index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: group.image != null ? NetworkImage(group.image!) : null,
                      child: group.image == null ? Text(group.name[0]) : null,
                    ),
                    title: Text(group.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${group.memberIds.length} members'),
                    onTap: () => _openGroupChat(context, group),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleGroupAction(value, group),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'info',
                          child: Text('Group Info'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'leave',
                          child: Text('Leave Group'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String groupName = '';
        File? imageFile;
        return AlertDialog(
          title: const Text('Create New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageFile != null
                  ? Image.file(imageFile, height: 100, width: 100, fit: BoxFit.cover)
                  : const Placeholder(fallbackHeight: 100, fallbackWidth: 100),
              TextField(
                onChanged: (value) {
                  groupName = value;
                },
                decoration: const InputDecoration(hintText: "Enter group name"),
              ),
              TextButton(
                child: const Text('Upload Image'),
                onPressed: () async {
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (groupName.isNotEmpty) {
                  _createGroup(groupName, imageFile);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSearchGroupDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchGroupScreen()),
    );
  }

  void _createGroup(String groupName, File? imageFile) async {
    Group newGroup = Group(
      id: '',
      name: groupName,
      memberIds: [APIs.user!.uid],
      createdBy: APIs.user!.uid,
      members: [APIs.user!.displayName ?? 'Unknown'],
      createdAt: DateTime.now().toIso8601String(),
      image: null,
    );

    bool success = await APIs.createGroup(newGroup, imageFile);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group "$groupName" created successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create group')),
      );
    }
  }

  void _openGroupChat(BuildContext context, Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupChatScreen(group: group)),
    );
  }

  void _handleGroupAction(String action, Group group) async {
    switch (action) {
      case 'info':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupInfoScreen(group: group)),
        );
        break;
      case 'leave':
        bool success = await APIs.leaveGroup(group.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Left group "${group.name}"')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to leave group')),
          );
        }
        break;
    }
  }
}
