// Reemplaza temporalmente tu secure_storage_datasource.dart con esta versión con logs

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile_model.dart';

abstract class SecureStorageDataSource {
  Future<void> saveUserProfile(UserProfileModel profile);
  Future<UserProfileModel?> getUserProfile();
  Future<void> deleteUserProfile();
  Future<bool> hasUserProfile();
}

class SecureStorageDataSourceImpl implements SecureStorageDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _userProfileKey = 'user_profile_secure';

  SecureStorageDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      print('🔥 DEBUG: Iniciando guardado de perfil...');
      print('🔥 DEBUG: Perfil a guardar: ${profile.nombre}');
      
      final jsonString = profile.toJsonString();
      print('🔥 DEBUG: JSON generado: $jsonString');
      print('🔥 DEBUG: Longitud del JSON: ${jsonString.length}');
      
      await secureStorage.write(key: _userProfileKey, value: jsonString);
      print('🔥 DEBUG: ✅ Guardado exitoso en storage');
      
      // Verificación inmediata
      final verification = await secureStorage.read(key: _userProfileKey);
      print('🔥 DEBUG: Verificación inmediata - datos leídos: ${verification != null ? "SÍ" : "NO"}');
      
    } catch (e) {
      print('🔥 DEBUG: ❌ Error al guardar: $e');
      throw Exception('Error al guardar el perfil en almacenamiento seguro: $e');
    }
  }

  @override
  Future<UserProfileModel?> getUserProfile() async {
    try {
      print('🔥 DEBUG: Iniciando lectura de perfil...');
      
      final jsonString = await secureStorage.read(key: _userProfileKey);
      print('🔥 DEBUG: Datos leídos del storage: ${jsonString != null ? "SÍ (${jsonString.length} chars)" : "NO"}');
      
      if (jsonString == null) {
        print('🔥 DEBUG: No hay datos en el storage');
        return null;
      }
      
      print('🔥 DEBUG: JSON leído: $jsonString');
      final profile = UserProfileModel.fromJsonString(jsonString);
      print('🔥 DEBUG: ✅ Perfil deserializado exitosamente: ${profile.nombre}');
      
      return profile;
    } catch (e) {
      print('🔥 DEBUG: ❌ Error al leer: $e');
      throw Exception('Error al obtener el perfil del almacenamiento seguro: $e');
    }
  }

  @override
  Future<void> deleteUserProfile() async {
    try {
      print('🔥 DEBUG: Eliminando perfil...');
      await secureStorage.delete(key: _userProfileKey);
      print('🔥 DEBUG: ✅ Perfil eliminado');
    } catch (e) {
      print('🔥 DEBUG: ❌ Error al eliminar: $e');
      throw Exception('Error al eliminar el perfil del almacenamiento seguro: $e');
    }
  }

  @override
  Future<bool> hasUserProfile() async {
    try {
      print('🔥 DEBUG: Verificando existencia de perfil...');
      final value = await secureStorage.read(key: _userProfileKey);
      final exists = value != null;
      print('🔥 DEBUG: Perfil existe: $exists');
      return exists;
    } catch (e) {
      print('🔥 DEBUG: ❌ Error al verificar existencia: $e');
      return false;
    }
  }
}