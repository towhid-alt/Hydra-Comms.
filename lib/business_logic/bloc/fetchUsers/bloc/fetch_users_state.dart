part of 'fetch_users_bloc.dart';

sealed class FetchUsersState extends Equatable {
  const FetchUsersState();
  
  @override
  List<Object> get props => [];
}

final class FetchUsersInitial extends FetchUsersState {}

class FetchUsersLoading extends FetchUsersState {}

class FetchUsersLoaded extends FetchUsersState {
  final List users; // This variable might cause some error

  const FetchUsersLoaded({required this.users});

  @override
  List<Object> get props => [users];
}

class FetchUsersError extends FetchUsersState {}
