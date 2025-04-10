import 'package:flutter/material.dart';
import 'package:chatai/models/personality.dart';
import 'package:chatai/providers/chat_provider.dart';
import 'package:chatai/screens/chat_screen.dart';
import 'package:provider/provider.dart';


class FriendItemWidget extends StatelessWidget {
  const FriendItemWidget({super.key, required this.friend});

  final Personality friend;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        leading: const CircleAvatar(
          radius: 30,
          child: Icon(Icons.person), // Placeholder avatar
        ),
        title: Text(
          friend.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${friend.title}\n${friend.traits.join(', ')}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: () async {
          // Navigate to chat screen with this AI personality
          final chatProvider = context.read<ChatProvider>();
          await chatProvider.prepareChatRoom(isNewChat: true, aiId: friend.id);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(personality: friend),
            ),
          );
        },
      ),
    );
  }
}
