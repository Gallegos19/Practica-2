import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login(String username, String password);
  Future<void> logout();
  Future<AuthSession?> getCurrentSession();
  Future<void> updateLastActivity();
  Future<void> saveSession(AuthSession session);
  Future<bool> isSessionValid();
  Future<void> clearSession();
}