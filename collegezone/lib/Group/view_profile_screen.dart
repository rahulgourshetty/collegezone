import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/models/chat_user.dart';

class ViewProfileScreen extends StatelessWidget {
  final String userId;

  const ViewProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatUser?>(
      future: APIs.getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('User not found'));
        }
        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(user.name),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
                  child: user.image == null ? Text(user.name[0], style: const TextStyle(fontSize: 32)) : null,
                ),
                const SizedBox(height: 16),
                Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(user.email, style: const TextStyle(fontSize: 16)),
                // Add more details if necessary
              ],
            ),
          ),
        );
      },
    );
  }
}
