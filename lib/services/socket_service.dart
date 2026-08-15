// lib/services/socket_service.dart
import 'package:chat_app/business_logic/bloc/chat/chat_bloc.dart';
import 'package:chat_app/business_logic/bloc/chat/chat_event.dart';
import 'package:http/http.dart' as context;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  bool isConnected = false;

  // Connect to the server
  void connect(String userId) {
    socket = IO.io(
      'https://interroad-nontragical-odessa.ngrok-free.dev',
      <String, dynamic>{
        //TODO: Change the server url
        'transports': ['websocket'],
        'autoConnect': true,
        'query': {'userId': userId},
      },
    );

    socket.onConnect((_) {
      print('Socket connected');
      isConnected = true;
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      isConnected = false;
    });

    socket.onConnectError((error) {
      print('Connection error: $error');
    });

    socket.connect();
  }

  // Send a message
  void sendMessage(Message message) {
    if (isConnected) {
      socket.emit('sendMessage', {
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'text': message.text,
      });
    }
  }

  // Listen for incoming messages
  void onMessageReceived(Function(Message) callback) {
    print('🟢 Registering onMessageReceived listener');
    //socket.off('receiveMessage');//FIXME: It is turning off all the listeners thats y event is not firing
    socket.on('receiveMessage', (data) {
      print('🚩socket.on of receiveMessage event running');
      print('📦 Received data: $data');
      try {
        final message = Message.fromJson(data);
        print('✅ Message parsed: ${message.text}');
        callback(message);
        print('🛑Turning off \'receiveMessage\' event');//FIXME:
        socket.off('receiveMessage');
      } catch (e) {
        print('❌ Error parsing message: $e');
      }
    });
  }

  // Disconnect
  void disconnect() {
    if (isConnected) {
      socket.disconnect();
      socket.dispose();
    }
  }
}
