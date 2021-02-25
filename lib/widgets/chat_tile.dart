import 'package:flutter/material.dart';

import '../helper/shared_prefs.dart';
import '../pages/chat_page.dart';

class ChatTile extends StatelessWidget {
  final String chatId; // groupId or chatRoomId
  final String chatName; // groupName or receiverName
  final bool isGroup;

  ChatTile({this.chatId, this.chatName, this.isGroup});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: chatId,
              chatName: chatName,
              isGroup: isGroup,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30.0,
            backgroundColor: Colors.red,
            child: Text(chatName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)),
          ),
          title: Text(chatName, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              isGroup
                  ? "Join the conversation as ${sharedPrefs.getName}"
                  : "continue conversation with $chatName",
              style: TextStyle(fontSize: 13.0)),
        ),
      ),
    );
  }
}
