import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login(String username, String password);
  Future<AuthSession> createAccount(String email, String password, String name);
  Future<void> logout();
  Future<void> deleteAccount();
  Future<AuthSession?> getCurrentSession();
  Future<void> updateLastActivity();
  Future<void> saveSession(AuthSession session);
  Future<bool> isSessionValid();
  Future<void> clearSession();
  Future<bool> hasRegisteredAccount();
  Future<Map<String, String>?> getStoredCredentials();
}