import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class SaveUserProfileUseCase {
  final UserProfileRepository repository;

  SaveUserProfileUseCase(this.repository);

  Future<void> call(UserProfile profile) async {
    // Validaciones de negocio
    if (profile.nombre.trim().isEmpty) {
      throw Exception('El nombre es requerido');
    }
    
    if (profile.correoElectronico.trim().isEmpty || !_isValidEmail(profile.correoElectronico)) {
      throw Exception('El correo electrónico no es válido');
    }
    
    if (profile.edad < 1 || profile.edad > 120) {
      throw Exception('La edad debe estar entre 1 y 120 años');
    }

    await repository.saveProfile(profile);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}