import '../repositories/user_profile_repository.dart';

class UpdateActivityProgressUseCase {
  final UserProfileRepository repository;

  UpdateActivityProgressUseCase(this.repository);

  Future<void> call(String actividad, double progreso) async {
    if (progreso < 0 || progreso > 100) {
      throw Exception('El progreso debe estar entre 0 y 100');
    }
    
    if (actividad.trim().isEmpty) {
      throw Exception('El nombre de la actividad es requerido');
    }

    await repository.updateActivityProgress(actividad, progreso);
  }
}