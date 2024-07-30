import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/models/group.dart';

class SearchGroupScreen extends StatefulWidget {
  const SearchGroupScreen({Key? key}) : super(key: key);

  @override
  _SearchGroupScreenState createState() => _SearchGroupScreenState();
}

class _SearchGroupScreenState extends State<SearchGroupScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Group> _allGroups = [];
  List<Group> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllGroups();
  }

  Future<void> _fetchAllGroups() async {
    try {
      var results = await APIs.getAllGroups();
      setState(() {
        _allGroups = results.docs.map((doc) => Group.fromJson(doc.data() as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Groups'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Enter group name',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) => _performSearch(value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchController.text.isEmpty ? _allGroups.length : _searchResults.length,
                    itemBuilder: (context, index) {
                      final group = _searchController.text.isEmpty ? _allGroups[index] : _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: group.image != null ? NetworkImage(group.image!) : null,
                          child: group.image == null ? Text(group.name[0]) : null,
                        ),
                        title: Text(group.name),
                        subtitle: Text('${group.memberIds.length} members'),
                        trailing: ElevatedButton(
                          child: const Text('Join'),
                          onPressed: () => _joinGroup(group),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      try {
        var results = await APIs.searchGroups(query);
        setState(() {
          _searchResults = results.docs.map((doc) => Group.fromJson(doc.data() as Map<String, dynamic>)).toList();
        });
      } catch (e) {
        print('Error: $e');
      }
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _joinGroup(Group group) async {
    bool success = await APIs.joinGroup(group.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined group "${group.name}"')),
      );
      Navigator.pop(context); // Go back to the home page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join group')),
      );
    }
  }
}
