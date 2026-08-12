// lib/bloc/chat_state.dart
import 'package:chat_app/models/message.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConnected extends ChatState {
  final List<Message> messages;
  final bool isConnected;

  const ChatConnected({
    required this.messages,
    required this.isConnected,
  });

  @override
  List<Object?> get props => [messages, isConnected];
}

class ChatError extends ChatState {
  final String error;

  const ChatError({required this.error});

  @override
  List<Object?> get props => [error];
}