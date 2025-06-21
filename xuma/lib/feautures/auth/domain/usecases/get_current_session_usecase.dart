import 'package:xuma/feautures/auth/domain/entities/auth_session.dart';
import 'package:xuma/feautures/auth/domain/repositories/auth_repository.dart';

class GetCurrentSessionUseCase {
  final AuthRepository repository;

  GetCurrentSessionUseCase(this.repository);

  Future<AuthSession?> call() async {
    return await repository.getCurrentSession();
  }
}
