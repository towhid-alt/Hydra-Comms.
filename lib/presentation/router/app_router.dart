import 'package:chat_app/business_logic/bloc/auth/auth_bloc.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  final AuthBloc _authBloc = AuthBloc(authService: AuthService(
    baseUrl: 'https://interroad-nontragical-odessa.ngrok-free.dev', // Change this based on your environment
  ));
  
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/': //Never miss this case, its the default route when the app starts
        return MaterialPageRoute(builder: (_) => BlocProvider.value(
          value: _authBloc,
          child: const LoginScreen()));
      case '/home':
        return MaterialPageRoute(builder: (_) => BlocProvider.value(
          value: _authBloc,
          child:  HomeScreen()));
      case '/login':
        return MaterialPageRoute(builder: (_) => BlocProvider.value(
          value: _authBloc,
          child: const LoginScreen()));
      case '/chat':
        final args = settings.arguments as Map<String, dynamic>;
        final otherUserId = args['otherUserId'];
        final otherUsername = args['otherUsername'];

        //Getting user info from the AuthBloc
        final authState = _authBloc.state;
        final currentUserId = authState is AuthAuthenticated ? authState.userId: '';
        final currentUsername = authState is AuthAuthenticated? authState.username : '';
        return MaterialPageRoute(builder: (_) => BlocProvider.value(
          value: _authBloc,
          child: ChatScreen(currentUserId: currentUserId, currentUsername: currentUsername, otherUserId: otherUserId, otherUsername: otherUsername,),));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  void dispose() {
    _authBloc.close();
  }
}