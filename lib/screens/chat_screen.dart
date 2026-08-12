// lib/screens/chat_screen.dart
import 'package:chat_app/business_logic/bloc/chat/chat_bloc.dart';
import 'package:chat_app/business_logic/bloc/chat/chat_event.dart';
import 'package:chat_app/business_logic/bloc/chat/chat_state.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Connect to socket when screen loads
    context.read<ChatBloc>().add(
      ConnectSocketEvent(userId: widget.currentUserId),
    );
    fetchChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    context.read<ChatBloc>().add(DisconnectSocketEvent());
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<ChatBloc>().add(
        SendMessageEvent(
          text: _messageController.text.trim(),
          receiverId: widget.receiverId,
        ),
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  Future<void> fetchChatHistory() async {
    try {
      context.read<ChatBloc>().add(
        FetchChatEvent(
          currentUserId: widget.currentUserId,
          receiverId: widget.receiverId,
        ),
      );
    } catch (e) {
      print('Error fetching chat history: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatError) {
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.error,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(
                        ConnectSocketEvent(userId: widget.currentUserId),
                      );
                    },
                    child: const Text('Reconnect'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatConnected) {
            return Column(
              children: [
                // Messages List
                Expanded(
                  child: state.messages.isEmpty
                      ? const Center(
                          child: Text(
                            'No messages yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isOwnMessage =
                                message.senderId == widget.currentUserId;

                            return _buildMessageItem(
                              message: message,
                              isOwnMessage: isOwnMessage,
                            );
                          
                          },
                        ),
                ),
                // Message Input
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Initializing chat...'));
        },
      ),
    );
  }

  Widget _buildMessageItem({
    required Message message,
    required bool isOwnMessage,
  }) {
    //FIXME:
    /*
    //Call after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearMessages();
    });*/

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isOwnMessage ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isOwnMessage ? const Radius.circular(4) : null,
            bottomLeft: isOwnMessage ? null : const Radius.circular(4),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isOwnMessage ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: isOwnMessage
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
