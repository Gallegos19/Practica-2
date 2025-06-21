import 'package:xuma/feautures/auth/domain/repositories/auth_repository.dart';

class CheckSessionValidityUseCase {
  final AuthRepository repository;

  CheckSessionValidityUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isSessionValid();
  }
}