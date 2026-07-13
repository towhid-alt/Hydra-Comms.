import 'package:chat_app/business_logic/bloc/auth_bloc.dart';
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
      case '/home':
        return MaterialPageRoute(builder: (_) => BlocProvider.value(
          value: _authBloc,
          child: const HomeScreen()));
      case '/login':
        return MaterialPageRoute(builder: (_) => BlocProvider.value(
          value: _authBloc,
          child: const LoginScreen()));
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