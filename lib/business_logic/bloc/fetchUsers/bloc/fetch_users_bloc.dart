import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'fetch_users_event.dart';
part 'fetch_users_state.dart';

class FetchUsersBloc extends Bloc<FetchUsersEvent, FetchUsersState> {
  FetchUsersBloc() : super(FetchUsersInitial()) {
    on<FetchUsers>(_fetchUsers);
  }

  Future<void> _fetchUsers(
    FetchUsers event,
    Emitter<FetchUsersState> emit,
  ) async {
    emit(FetchUsersLoading());

    try {
      final response = await http.get(Uri.parse('https://interroad-nontragical-odessa.ngrok-free.dev/api/users'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(FetchUsersLoaded(users: data['users']));
      }
    } catch (error) {
      print('Error fetching users: $error');
      emit(FetchUsersError());
    }
  }
}
