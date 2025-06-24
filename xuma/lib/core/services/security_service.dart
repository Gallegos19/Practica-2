import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xuma/feautures/auth/domain/repositories/auth_repository.dart';
import 'package:xuma/feautures/login/domain/repositories/user_profile_repository.dart';
import 'package:xuma/di/injection_container.dart' as di;

class SecurityService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Elimina todos los datos sensibles de la aplicación
  static Future<void> emergencyDataWipe() async {
    try {
      print('🚨 EMERGENCY DATA WIPE: Iniciando borrado de emergencia...');
      
      // 1. Eliminar datos de autenticación
      await _clearAuthData();
      
      // 2. Eliminar perfil de usuario
      await _clearUserProfile();
      
      // 3. Limpiar todo el secure storage
      await _clearAllSecureStorage();
      
      // 4. Log de confirmación
      print('🚨 EMERGENCY DATA WIPE: Todos los datos sensibles han sido eliminados');
      
      // 5. Opcional: Guardar timestamp del borrado
      await _logDataWipeEvent();
      
    } catch (e) {
      print('🚨 ERROR en borrado de emergencia: $e');
      // Aún así, intentar limpiar el storage completo como fallback
      await _clearAllSecureStorageFallback();
    }
  }

  /// Verifica si el mensaje es una orden de borrado de emergencia
  static bool isEmergencyWipeMessage(String? title, String? body) {
    if (title == null || body == null) return false;
    
    // Verificar título y mensaje específicos
    final titleMatch = title.toLowerCase().contains('peligro');
    final bodyMatch = body.toLowerCase().contains('por seguridad') && 
                     body.toLowerCase().contains('datos') && 
                     body.toLowerCase().contains('borrados');
    
    return titleMatch && bodyMatch;
  }

  /// Limpia datos de autenticación usando el repositorio
  static Future<void> _clearAuthData() async {
    try {
      final authRepository = di.sl<AuthRepository>();
      await authRepository.logout();
      await authRepository.deleteAccount();
      print('🚨 Datos de autenticación eliminados');
    } catch (e) {
      print('🚨 Error al eliminar datos de auth: $e');
    }
  }

  /// Limpia perfil de usuario usando el repositorio
  static Future<void> _clearUserProfile() async {
    try {
      final userProfileRepository = di.sl<UserProfileRepository>();
      await userProfileRepository.deleteProfile();
      print('🚨 Perfil de usuario eliminado');
    } catch (e) {
      print('🚨 Error al eliminar perfil: $e');
    }
  }

  /// Limpia todo el secure storage
  static Future<void> _clearAllSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
      print('🚨 Secure storage completamente limpiado');
    } catch (e) {
      print('🚨 Error al limpiar secure storage: $e');
    }
  }

  /// Fallback: Limpia storage individualmente si deleteAll falla
  static Future<void> _clearAllSecureStorageFallback() async {
    try {
      // Listas de claves conocidas que debemos eliminar
      final keysToDelete = [
        'auth_session_secure',
        'user_credentials_secure', 
        'user_profile_secure',
        // Agregar más claves según sea necesario
      ];
      
      for (String key in keysToDelete) {
        try {
          await _secureStorage.delete(key: key);
          print('🚨 Eliminada clave: $key');
        } catch (e) {
          print('🚨 Error al eliminar clave $key: $e');
        }
      }
    } catch (e) {
      print('🚨 Error en fallback cleanup: $e');
    }
  }

  /// Registra el evento de borrado de emergencia
  static Future<void> _logDataWipeEvent() async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      await _secureStorage.write(
        key: 'last_emergency_wipe', 
        value: timestamp
      );
      print('🚨 Evento de borrado registrado: $timestamp');
    } catch (e) {
      print('🚨 Error al registrar evento de borrado: $e');
    }
  }

  /// Verifica si hubo un borrado de emergencia reciente
  static Future<String?> getLastEmergencyWipe() async {
    try {
      return await _secureStorage.read(key: 'last_emergency_wipe');
    } catch (e) {
      print('🚨 Error al obtener último borrado: $e');
      return null;
    }
  }

  /// Limpia solo el log de borrado (para testing)
  static Future<void> clearEmergencyWipeLog() async {
    try {
      await _secureStorage.delete(key: 'last_emergency_wipe');
    } catch (e) {
      print('🚨 Error al limpiar log de borrado: $e');
    }
  }

  /// Obtiene información del estado de seguridad
  static Future<Map<String, dynamic>> getSecurityStatus() async {
    try {
      final lastWipe = await getLastEmergencyWipe();
      final allKeys = await _secureStorage.readAll();
      
      return {
        'lastEmergencyWipe': lastWipe,
        'storedKeysCount': allKeys.length,
        'hasUserData': allKeys.containsKey('user_profile_secure'),
        'hasAuthData': allKeys.containsKey('auth_session_secure'),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('🚨 Error al obtener estado de seguridad: $e');
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}