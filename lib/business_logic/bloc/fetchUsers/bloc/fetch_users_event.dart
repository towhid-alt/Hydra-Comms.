part of 'fetch_users_bloc.dart';

sealed class FetchUsersEvent extends Equatable {
  const FetchUsersEvent();

  @override
  List<Object> get props => [];
}

class FetchUsers extends FetchUsersEvent {}
