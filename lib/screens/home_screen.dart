import 'package:chat_app/business_logic/bloc/auth_bloc.dart';
import 'package:chat_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false, // Removes all previous routes
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.home, color: Colors.white),
            backgroundColor: Colors.red,
            title: const Text(
              'Hydra Teammates',
              style: TextStyle(color: Colors.white, fontFamily: 'Code'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  // Handle logout action
                  context.read<AuthBloc>().add(LogoutRequested());
                },
              ),
            ],
          ),
          body: const Center(child: Text('Welcome to the Home Screen!')),
        );
      },
    );
  }
}
