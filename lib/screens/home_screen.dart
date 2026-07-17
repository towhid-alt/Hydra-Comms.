import 'package:chat_app/business_logic/bloc/auth/auth_bloc.dart';
import 'package:chat_app/business_logic/bloc/fetchUsers/bloc/fetch_users_bloc.dart';
import 'package:chat_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // bool isLoading = true;

  Future<void> fetchUsers() async {
    context.read<FetchUsersBloc>().add(FetchUsers());
  }
  
  @override
  void initState() {
    super.initState();
    fetchUsers();
  } 

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
          body: BlocBuilder<FetchUsersBloc, FetchUsersState>(
            builder: (context, state) {
              if (state is FetchUsersInitial) {
                return const Center(child: Text('FetchUsersInitial state', style: TextStyle(color: Colors.green)));
              } else if (state is FetchUsersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FetchUsersLoaded) {
                final users = state.users;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user['username']),
                      //subtitle: Text('ID: ${user['id']}'),
                    );
                  },
                );
              } else if (state is FetchUsersError) {
                return const Center(
                  child: Text(
                    'Error fetching users',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
