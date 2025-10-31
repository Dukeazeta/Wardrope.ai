import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<AuthRegistrationCompleted>(_onAuthRegistrationCompleted);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) {
    // Check if user is already authenticated (e.g., from local storage)
    // For now, we'll emit unauthenticated state
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      userId: event.userId,
      email: event.email,
    ));
  }

  void _onAuthLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      userId: null,
      email: null,
    ));
  }

  void _onAuthRegistrationCompleted(
    AuthRegistrationCompleted event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      userId: event.userId,
      email: event.email,
    ));
  }
}