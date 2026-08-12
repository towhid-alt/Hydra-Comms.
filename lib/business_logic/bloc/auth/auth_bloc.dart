import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) { //set the foundation first
    on<LoginRequested>(_onLoginRequested); //then build the walls
    on<LogoutRequested>(_onLogoutRequested); //Event Handlers- telling bloc which functions to call for each event type
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await authService.login(// call the login function that talks to your server
        username: event.username,
        password: event.password,
      );

      if (response['success']) {
        emit(AuthAuthenticated( userId: response['userId'], username: event.username));
        
      } else {
        emit(AuthError(message: response['error'] ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    authService.logout();
    emit(AuthUnauthenticated());
  }
}

class AuthService {
  final String baseUrl;

  AuthService({this.baseUrl = 'https://interroad-nontragical-odessa.ngrok-free.dev'}); // Change to your server IP for physical device

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},// Tells the server "I'm sending JSON data"
        body: jsonEncode({ //Converts the Dart map to a JSON string
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body); // Converts the server's JSON response back into a Dart object (Map<String, dynamic>)

      if (response.statusCode == 200) {
       final userId = data['userId'] ?? '';
       //Converting userId to string to avoid type issues
       final userIdString = userId.toString();
       print('  ✅ Login successful for user: $username, userId: $userId');
        return {'success': true, 'message': data['message'], 'userId': userIdString};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  void logout() {
    
  }
}