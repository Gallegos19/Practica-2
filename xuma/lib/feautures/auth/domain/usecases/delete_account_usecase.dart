import 'package:xuma/feautures/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call() async {
    await repository.deleteAccount();
  }
}