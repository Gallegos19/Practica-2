import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class GetUserProfileUseCase {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfile?> call() async {
    return await repository.getProfile();
  }
}
