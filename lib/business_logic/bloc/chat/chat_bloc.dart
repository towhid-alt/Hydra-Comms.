// lib/bloc/chat_bloc.dart
import 'dart:convert';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SocketService _socketService = SocketService();
  final Uuid _uuid = const Uuid();

  String currentUserId = ''; 
  List<Message> messages = [];

  ChatBloc() : super(ChatInitial()) {
    on<ConnectSocketEvent>(_onConnectSocket);
    on<DisconnectSocketEvent>(_onDisconnectSocket);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<FetchChatEvent>(_onFetchChatHistory);
    on<ClearMessageEvent>(_onClearMessages);
  }

  // Handle socket connection
  void _onConnectSocket(
    ConnectSocketEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());

      currentUserId = event.userId;
      //messages.clear();
      //print('🚮Local messages list cleared on Connect socket');//FIXME:

      


      // Connect to socket
      _socketService.connect(event.userId);

      
      // Listen for incoming messages
      _socketService.onMessageReceived((message) {//TODO: Study this function in detail. VERY USEFUL!! UNDERSTAND THE CODE FLOW
        //This runs when a message is received from the socket
        // Add event to BLoC when message is received
        print('🧣Running ReceiveMessageEvent');
        add(ReceiveMessageEvent(message: message));
      });

      

      emit(ChatConnected(messages: messages, isConnected: true));
    } catch (e) {
      emit(ChatError(error: 'Failed to connect: $e'));
    }
  }

  // Handle disconnection
  void _onDisconnectSocket(
    DisconnectSocketEvent event,
    Emitter<ChatState> emit,
  ) {
    _socketService.disconnect();
    emit(ChatInitial());
  }

  // Handle sending message
  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) {
    try {
      // Create new message
      final message = Message(
        id: _uuid.v4(),
        text: event.text,
        senderId: currentUserId,
        receiverId: event.receiverId,
        timestamp: DateTime.now(),
      );

      // Add to local list
      messages.add(message); 
      print(
        '📩Message: ${message.text}, Sender: ${message.senderId}, Receiver: ${message.receiverId}',
      );
      // Send through socket
      _socketService.sendMessage(message);

      // Update state
      if (state is ChatConnected) {
        print('👺Local List content in _sendMessage:${messages.length}');//FIXME:Debug code
        emit(ChatConnected(messages: messages, isConnected: true));
      }
    } catch (e) {
      emit(ChatError(error: 'Failed to send message: $e'));
    }
  }

  // Handle receiving message
  void _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) {
  
    
    print('🚩_onReceiveMessage code running');
    // Add received message to list
    messages.add(event.message);

    if (state is ChatConnected) {
      print('👺Local List content in _onReceiveMessage:${messages.length}');//FIXME:Debug code
      emit(ChatConnected(messages: messages, isConnected: true));
    }
  //messages.clear();//FIXME:So that the whole local list doesnt get built again in UI
  }

  void _onFetchChatHistory(
    FetchChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final response = await http.get(
        Uri.parse(
          'https://interroad-nontragical-odessa.ngrok-free.dev/api/chat/${event.currentUserId}/${event.receiverId}',
        ),
      );
      if (response.statusCode == 200) {
        print('✅Chat history fetched successfully');
        final List<dynamic> data = jsonDecode(response.body);
        // Converting to Message model
        final List<Message> fetchedMessages = data
            .map((messageJson) => Message.fromJson(messageJson))
            .toList();

        //messages.addAll(fetchedMessages);//FIXME: There is no need to add to local list here
        emit(ChatConnected(messages: fetchedMessages, isConnected: true));
      }
    } catch (e) {
      emit(ChatError(error: '❌Failed to fetch chat history: $e'));
    }
  }
  
  void _onClearMessages(
    ClearMessageEvent event,
    Emitter<ChatState> emit,
  ) {
    messages.clear();
    print('Local message list cleared. Current length: ${messages.length}');
  }
  

  @override
  Future<void> close() {
    _socketService.disconnect();
    return super.close();
  }
}
