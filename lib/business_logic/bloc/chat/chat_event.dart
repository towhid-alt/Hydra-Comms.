// lib/bloc/chat_event.dart
import 'package:chat_app/models/message.dart';
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// Event to send a new message
class SendMessageEvent extends ChatEvent {
  final String text;
  final String receiverId;

  const SendMessageEvent({
    required this.text,
    required this.receiverId,
  });

  @override
  List<Object?> get props => [text, receiverId];
}

// Event to receive a new message from socket
class ReceiveMessageEvent extends ChatEvent {
  final Message message;

  const ReceiveMessageEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

// Event to initialize socket connection
class ConnectSocketEvent extends ChatEvent {
  final String userId;

  const ConnectSocketEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

//Event to fetch chat history
class FetchChatEvent extends ChatEvent {
  final String currentUserId;
  final String receiverId;

  const FetchChatEvent({
    required this.currentUserId,
    required this.receiverId,
  });

  @override
  List<Object?> get props => [currentUserId, receiverId];
}

// Event to disconnect socket
class DisconnectSocketEvent extends ChatEvent {}

class ClearMessageEvent extends ChatEvent {}