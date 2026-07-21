import 'package:chat_app/business_logic/bloc/auth/auth_bloc.dart';
import 'package:chat_app/business_logic/bloc/fetchUsers/bloc/fetch_users_bloc.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
          Navigator.pushNamedAndRemoveUntil(
            context, '/login',
             (route) => false, // Removes all previous routes
          );
        }
      },
      builder: (context, state) {
        //Safely extract the current username
        final currentUser = state is AuthAuthenticated ? state.username : '';
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
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.white,
                    thickness: 1,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final username = user['username'];
                    print('Current user - $currentUser');
                    final displayName = (username == currentUser) ? '$username (You)' : username;
                    return ListTile(
                      title: Text(displayName, 
                      style:  const TextStyle(color: Colors.white, fontFamily: 'Code',fontSize: 25)),
                      //subtitle: Text('ID: ${user['id']}'),
                      onTap: () {
                        Navigator.pushNamed(context, '/chat');
                      },
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
