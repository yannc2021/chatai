import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatai/providers/friends_provider.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    await Provider.of<FriendsProvider>(context, listen: false).loadFriends();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final personalities = context.watch<FriendsProvider>().friends;

    return Scaffold(
      appBar: AppBar(title: const Text('Your AI Friends')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : personalities.isEmpty
              ? const Center(child: Text('No friends found.'))
              : ListView.builder(
                itemCount: personalities.length,
                itemBuilder: (context, index) {
                  final personality = personalities[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(personality.name),
                      subtitle: Text(
                        personality.traits.join(', '),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Navigate to chat or profile screen
                      },
                    ),
                  );
                },
              ),
    );
  }
}
