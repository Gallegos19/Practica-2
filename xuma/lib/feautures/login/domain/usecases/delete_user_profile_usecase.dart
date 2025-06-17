import '../repositories/user_profile_repository.dart';

class DeleteUserProfileUseCase {
  final UserProfileRepository repository;

  DeleteUserProfileUseCase(this.repository);

  Future<void> call() async {
    await repository.deleteProfile();
  }
}
