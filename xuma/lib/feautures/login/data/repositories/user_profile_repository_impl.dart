import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasource/secure_storage_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final SecureStorageDataSource dataSource;

  UserProfileRepositoryImpl({required this.dataSource});

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final model = UserProfileModel.fromEntity(profile);
    await dataSource.saveUserProfile(model);
  }

  @override
  Future<UserProfile?> getProfile() async {
    final model = await dataSource.getUserProfile();
    return model;
  }

  @override
  Future<void> deleteProfile() async {
    await dataSource.deleteUserProfile();
  }

  @override
  Future<bool> profileExists() async {
    return await dataSource.hasUserProfile();
  }

  @override
  Future<void> updateActivityProgress(String actividad, double progreso) async {
    final currentProfile = await getProfile();
    if (currentProfile != null) {
      final updatedProgress = Map<String, double>.from(currentProfile.progresoActividades);
      updatedProgress[actividad] = progreso;
      
      final updatedProfile = currentProfile.copyWith(
        progresoActividades: updatedProgress,
      );
      
      await saveProfile(updatedProfile);
    }
  }
}