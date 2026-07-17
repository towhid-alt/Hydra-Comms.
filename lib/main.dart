import 'package:chat_app/business_logic/bloc/auth/auth_bloc.dart';
import 'package:chat_app/business_logic/bloc/fetchUsers/bloc/fetch_users_bloc.dart';
import 'package:chat_app/presentation/router/app_router.dart';
import 'package:chat_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: AuthService(
              // For Android emulator use 'http://10.0.2.2:3000'
              // For iOS simulator use 'http://localhost:3000'
              // For physical device use your computer's IP address
              baseUrl: 'https://interroad-nontragical-odessa.ngrok-free.dev', // Change this based on your environment
            ),
          ),
        ),

        BlocProvider<FetchUsersBloc>(
          create: (context) => FetchUsersBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Hydra Comms',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          primarySwatch: Colors.red,
          useMaterial3: true,
        ),
        onGenerateRoute: _appRouter.onGenerateRoute,
        initialRoute: '/',
      ),
    );
  }

  @override 
  void dispose() {
    _appRouter.dispose();
    
  }
}