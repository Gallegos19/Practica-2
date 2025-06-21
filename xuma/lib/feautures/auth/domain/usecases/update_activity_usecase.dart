import 'package:xuma/feautures/auth/domain/repositories/auth_repository.dart';

class UpdateActivityUseCase {
  final AuthRepository repository;

  UpdateActivityUseCase(this.repository);

  Future<void> call() async {
    await repository.updateLastActivity();
  }
}