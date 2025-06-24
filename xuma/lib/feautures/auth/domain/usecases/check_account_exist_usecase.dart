import 'package:xuma/feautures/auth/domain/repositories/auth_repository.dart';

class CheckAccountExistsUseCase {
  final AuthRepository repository;

  CheckAccountExistsUseCase(this.repository);

  Future<bool> call() async {
    return await repository.hasRegisteredAccount();
  }
}