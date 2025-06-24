import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xuma/feautures/auth/data/model/auth_session_model.dart';
import 'package:xuma/feautures/auth/domain/entities/auth_session.dart';
import 'package:xuma/feautures/auth/domain/repositories/auth_repository.dart';
import 'package:xuma/feautures/login/data/datasource/secure_storage_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageDataSource dataSource;
  static const String _sessionKey = 'auth_session_secure';
  static const String _credentialsKey = 'user_credentials_secure';
  
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
    print('🔐 AUTH: Intentando login para usuario: $username');
    
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }
    
    // Validar formato de email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}')
        .hasMatch(username)) {
      throw Exception('Por favor ingresa un email válido');
    }
    
    // Verificar si existen credenciales guardadas
    final storedCredentials = await _getStoredCredentials();
    
    if (storedCredentials == null) {
      throw Exception('No hay cuenta registrada. Por favor crea una cuenta primero.');
    }
    
    // Validar credenciales
    if (storedCredentials['email'] != username || 
        storedCredentials['password'] != password) {
      throw Exception('Email o contraseña incorrectos');
    }
    
    // Simulamos un delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Crear nueva sesión
    final session = AuthSessionModel(
      token: AuthSessionModel.generateToken(),
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
      timeoutMinutes: 1, // 15 minutos de timeout
      isActive: true,
    );
    
    // Guardar sesión en almacenamiento seguro
    await saveSession(session);
    
    print('🔐 AUTH: Login exitoso para: $username');
    return session;
  }

  @override
  Future<AuthSession> createAccount(String email, String password, String name) async {
    print('🔐 AUTH: Creando cuenta para usuario: $email');
    
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Todos los campos son requeridos');
    }
    
    // Validar formato de email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}')
        .hasMatch(email)) {
      throw Exception('Por favor ingresa un email válido');
    }
    
    if (password.length < 4) {
      throw Exception('La contraseña debe tener al menos 4 caracteres');
    }
    
    // Verificar si ya existe una cuenta
    final existingCredentials = await _getStoredCredentials();
    if (existingCredentials != null) {
      throw Exception('Ya existe una cuenta registrada. Usa el login para acceder.');
    }
    
    // Simulamos un delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Guardar credenciales
    await _saveCredentials(email, password, name);
    
    // Crear nueva sesión
    final session = AuthSessionModel(
      token: AuthSessionModel.generateToken(),
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
      timeoutMinutes: 1,
      isActive: true,
    );
    
    // Guardar sesión en almacenamiento seguro
    await saveSession(session);
    
    print('🔐 AUTH: Cuenta creada exitosamente para: $email');
    return session;
  }

  @override
  Future<bool> hasRegisteredAccount() async {
    try {
      final credentials = await _getStoredCredentials();
      return credentials != null;
    } catch (e) {
      print('🔐 AUTH: Error al verificar cuenta existente: $e');
      return false;
    }
  }

  @override
  Future<Map<String, String>?> getStoredCredentials() async {
    return await _getStoredCredentials();
  }

  Future<Map<String, String>?> _getStoredCredentials() async {
    try {
      final credentialsData = await _secureStorage.read(key: _credentialsKey);
      if (credentialsData == null) return null;
      
      final Map<String, dynamic> credentials = 
          Map<String, dynamic>.from(jsonDecode(credentialsData));
      
      return {
        'email': credentials['email'] ?? '',
        'password': credentials['password'] ?? '',
        'name': credentials['name'] ?? '',
      };
    } catch (e) {
      print('🔐 AUTH: Error al leer credenciales: $e');
      return null;
    }
  }

  Future<void> _saveCredentials(String email, String password, String name) async {
    try {
      final credentials = {
        'email': email,
        'password': password,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final jsonString = jsonEncode(credentials);
      await _secureStorage.write(key: _credentialsKey, value: jsonString);
      
      print('🔐 AUTH: Credenciales guardadas exitosamente');
    } catch (e) {
      print('🔐 AUTH: Error al guardar credenciales: $e');
      throw Exception('Error al guardar las credenciales: $e');
    }
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
  Future<void> deleteAccount() async {
    print('🔐 AUTH: Eliminando cuenta...');
    
    try {
      // Cerrar sesión actual
      await logout();
      
      // Eliminar credenciales
      await _secureStorage.delete(key: _credentialsKey);
      
      print('🔐 AUTH: Cuenta eliminada exitosamente');
    } catch (e) {
      print('🔐 AUTH: Error al eliminar cuenta: $e');
      throw Exception('Error al eliminar la cuenta: $e');
    }
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