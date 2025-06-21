
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xuma/feautures/auth/data/model/auth_session_model.dart';
import 'package:xuma/feautures/auth/domain/entities/auth_session.dart';
import 'package:xuma/feautures/auth/domain/repositories/auth_repository.dart';
import 'package:xuma/feautures/login/data/datasource/secure_storage_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageDataSource dataSource;
  static const String _sessionKey = 'auth_session_secure';
  
  // Acceso directo al secure storage
  late final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl({required this.dataSource}) {
    // Acceder al secure storage a través del dataSource implementado
    if (dataSource is SecureStorageDataSourceImpl) {
      _secureStorage = (dataSource as SecureStorageDataSourceImpl).secureStorage;
    } else {
      throw Exception('DataSource debe ser SecureStorageDataSourceImpl');
    }
  }

@override
Future<AuthSession> login(String username, String password) async {
  // Aquí normalmente harías una llamada a tu API
  // Por ahora simulamos la autenticación con email/contraseña
  print('🔐 AUTH: Iniciando sesión para usuario: $username');
  
  // Simulación de validación de credenciales
  if (username.isEmpty || password.isEmpty) {
    throw Exception('Email y contraseña son requeridos');
  }
  
  // Validar formato de email
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}')
      .hasMatch(username)) {
    throw Exception('Por favor ingresa un email válido');
  }
  
  // Simulamos un delay de red
  await Future.delayed(const Duration(seconds: 1));
  
  // Crear nueva sesión (en una app real aquí validarías contra tu backend)
  final session = AuthSessionModel(
    token: AuthSessionModel.generateToken(),
    createdAt: DateTime.now(),
    lastActivity: DateTime.now(),
    timeoutMinutes: 15, // 15 minutos de timeout
    isActive: true,
  );
  
  // Guardar sesión en almacenamiento seguro
  await saveSession(session);
  
  print('🔐 AUTH: Sesión creada exitosamente para: $username');
  return session;
}

  @override
  Future<void> logout() async {
    print('🔐 AUTH: Cerrando sesión...');
    
    final currentSession = await getCurrentSession();
    if (currentSession != null) {
      // Marcar sesión como inactiva
      final inactiveSession = currentSession.copyWith(isActive: false);
      await saveSession(inactiveSession);
    }
    
    // Limpiar datos de sesión después de un breve delay
    await Future.delayed(const Duration(milliseconds: 500));
    await clearSession();
    
    print('🔐 AUTH: Sesión cerrada exitosamente');
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    try {
      print('🔐 AUTH: Obteniendo sesión actual...');
      
      final sessionData = await _secureStorage.read(key: _sessionKey);
      if (sessionData == null) {
        print('🔐 AUTH: No hay sesión guardada');
        return null;
      }
      
      final session = AuthSessionModel.fromJsonString(sessionData);
      print('🔐 AUTH: Sesión encontrada - Activa: ${session.isActive}, Expira en: ${session.minutesUntilExpiry} min');
      
      return session;
    } catch (e) {
      print('🔐 AUTH: Error al obtener sesión: $e');
      return null;
    }
  }

  @override
  Future<void> updateLastActivity() async {
    try {
      final currentSession = await getCurrentSession();
      if (currentSession != null && currentSession.isActive && !currentSession.isExpired) {
        final updatedSession = currentSession.copyWith(
          lastActivity: DateTime.now(),
        );
        await saveSession(updatedSession);
        print('🔐 AUTH: Actividad actualizada');
      }
    } catch (e) {
      print('🔐 AUTH: Error al actualizar actividad: $e');
    }
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    try {
      print('🔐 AUTH: Guardando sesión...');
      
      final sessionModel = AuthSessionModel.fromEntity(session);
      final jsonString = sessionModel.toJsonString();
      
      await _secureStorage.write(
        key: _sessionKey, 
        value: jsonString,
      );
      
      print('🔐 AUTH: Sesión guardada exitosamente');
    } catch (e) {
      print('🔐 AUTH: Error al guardar sesión: $e');
      throw Exception('Error al guardar la sesión: $e');
    }
  }

  @override
  Future<bool> isSessionValid() async {
    try {
      final session = await getCurrentSession();
      if (session == null) return false;
      
      final isValid = session.isActive && !session.isExpired;
      print('🔐 AUTH: Validez de sesión: $isValid');
      
      return isValid;
    } catch (e) {
      print('🔐 AUTH: Error al validar sesión: $e');
      return false;
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      print('🔐 AUTH: Limpiando datos de sesión...');
      await _secureStorage.delete(key: _sessionKey);
      print('🔐 AUTH: Datos de sesión eliminados');
    } catch (e) {
      print('🔐 AUTH: Error al limpiar sesión: $e');
      throw Exception('Error al eliminar la sesión: $e');
    }
  }
}