import 'package:equatable/equatable.dart';
import 'package:xuma/feautures/auth/domain/entities/auth_session.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class AuthInitial extends AuthState {}

// Estado de carga
class AuthLoading extends AuthState {}

// Estado autenticado
class AuthAuthenticated extends AuthState {
  final AuthSession session;

  const AuthAuthenticated({required this.session});

  @override
  List<Object> get props => [session];
}

// Estado no autenticado
class AuthUnauthenticated extends AuthState {}

// Estado de error
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// Estado de sesión expirada
class AuthSessionExpired extends AuthState {
  final String message;

  const AuthSessionExpired({this.message = 'Tu sesión ha expirado'});

  @override
  List<Object> get props => [message];
}

// Estado de advertencia de expiración próxima
class AuthSessionWarning extends AuthState {
  final AuthSession session;
  final int minutesRemaining;

  const AuthSessionWarning({
    required this.session,
    required this.minutesRemaining,
  });

  @override
  List<Object> get props => [session, minutesRemaining];
}