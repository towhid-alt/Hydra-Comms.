import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUsername;
  final String otherUserId;
  final String otherUsername;
  const ChatScreen({super.key,
  required this.currentUserId,
  required this.currentUsername,
  required this.otherUserId,
  required this.otherUsername
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('CHAT SCREEN', 
        style: TextStyle(fontSize: 20, color: Colors.amberAccent),)
      ),
    );
  }
}