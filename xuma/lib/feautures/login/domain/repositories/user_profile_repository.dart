import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<void> saveProfile(UserProfile profile);
  Future<UserProfile?> getProfile();
  Future<void> deleteProfile();
  Future<bool> profileExists();
  Future<void> updateActivityProgress(String actividad, double progreso);
}

