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
      final jsonString = profile.toJsonString();
      await secureStorage.write(key: _userProfileKey, value: jsonString);
    } catch (e) {
      throw Exception('Error al guardar el perfil en almacenamiento seguro: $e');
    }
  }

  @override
  Future<UserProfileModel?> getUserProfile() async {
    try {
      final jsonString = await secureStorage.read(key: _userProfileKey);
      if (jsonString == null) return null;
      
      return UserProfileModel.fromJsonString(jsonString);
    } catch (e) {
      throw Exception('Error al obtener el perfil del almacenamiento seguro: $e');
    }
  }

  @override
  Future<void> deleteUserProfile() async {
    try {
      await secureStorage.delete(key: _userProfileKey);
    } catch (e) {
      throw Exception('Error al eliminar el perfil del almacenamiento seguro: $e');
    }
  }

  @override
  Future<bool> hasUserProfile() async {
    try {
      final value = await secureStorage.read(key: _userProfileKey);
      return value != null;
    } catch (e) {
      return false;
    }
  }
}