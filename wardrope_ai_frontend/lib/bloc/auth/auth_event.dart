part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {
  final String userId;
  final String? email;

  const AuthLoggedIn({required this.userId, this.email});

  @override
  List<Object> get props => [userId, if (email != null) email!];
}

class AuthLoggedOut extends AuthEvent {}

class AuthRegistrationCompleted extends AuthEvent {
  final String userId;
  final String email;

  const AuthRegistrationCompleted({
    required this.userId,
    required this.email,
  });

  @override
  List<Object> get props => [userId, email];
}