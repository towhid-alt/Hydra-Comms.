// lib/models/message.dart
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  // Convert to JSON for sending over socket - FOR DATA OUT
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'senderId': senderId,
    'receiverId': receiverId,
    'timestamp': timestamp.toIso8601String(),
  };

  // Create from JSON - FOR DATA IN
  factory Message.fromJson(Map<String, dynamic> json) => Message(
    //Converting int to String
    id: json['id'].toString(),
    text: json['text'] ?? '',
    senderId: json['sender_id'].toString(),
    receiverId: json['receiver_id'].toString(),
    timestamp: DateTime.parse(json['sent_at']),
  );

  @override
  List<Object?> get props => [id, text, senderId, receiverId, timestamp];
}