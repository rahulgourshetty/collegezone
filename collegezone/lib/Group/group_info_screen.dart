import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/models/group.dart';
import 'package:we_chat/models/chat_user.dart';

class GroupInfoScreen extends StatelessWidget {
  final Group group;

  const GroupInfoScreen({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: group.image != null ? NetworkImage(group.image!) : null,
                  child: group.image == null ? Text(group.name[0], style: const TextStyle(fontSize: 32)) : null,
                ),
                const SizedBox(height: 16),
                Text(group.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Created on: ${_formatDate(group.createdAt)}'),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Members:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          FutureBuilder<List<ChatUser>>(
            future: APIs.getGroupMembers(group.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No members found'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final member = snapshot.data![index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member.image != null ? NetworkImage(member.image) : null,
                      child: member.image == null ? Text(member.name[0]) : null,
                    ),
                    title: Text(member.name),
                    subtitle: Text(member.email),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String createdAt) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(createdAt));
      return '${date.toLocal().toIso8601String().split('T').first} ${date.toLocal().toIso8601String().split('T').last.split('.').first}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}
