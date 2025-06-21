import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthSession> call(String email, String password) async {
    if (email.trim().isEmpty) {
      throw Exception('El correo electrónico es requerido');
    }
    
    if (password.trim().isEmpty) {
      throw Exception('La contraseña es requerida');
    }
    
    if (password.length < 4) {
      throw Exception('La contraseña debe tener al menos 4 caracteres');
    }

    // Validar formato de email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw Exception('Por favor ingresa un email válido');
    }

    return await repository.login(email, password);
  }
}