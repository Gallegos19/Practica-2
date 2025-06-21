import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  final String token;
  final DateTime createdAt;
  final DateTime? lastActivity;
  final int timeoutMinutes;
  final bool isActive;

  const AuthSession({
    required this.token,
    required this.createdAt,
    this.lastActivity,
    this.timeoutMinutes = 1, // 15 minutos por defecto
    this.isActive = true,
  });

  AuthSession copyWith({
    String? token,
    DateTime? createdAt,
    DateTime? lastActivity,
    int? timeoutMinutes,
    bool? isActive,
  }) {
    return AuthSession(
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      timeoutMinutes: timeoutMinutes ?? this.timeoutMinutes,
      isActive: isActive ?? this.isActive,
    );
  }

  // Verifica si la sesión ha expirado
  bool get isExpired {
    if (!isActive) return true;
    
    final lastActivityTime = lastActivity ?? createdAt;
    final now = DateTime.now();
    final difference = now.difference(lastActivityTime);
    
    return difference.inMinutes >= timeoutMinutes;
  }

  // Obtiene los minutos restantes antes de que expire la sesión
  int get minutesUntilExpiry {
    if (!isActive) return 0;
    
    final lastActivityTime = lastActivity ?? createdAt;
    final now = DateTime.now();
    final difference = now.difference(lastActivityTime);
    final remaining = timeoutMinutes - difference.inMinutes;
    
    return remaining > 0 ? remaining : 0;
  }

  @override
  List<Object?> get props => [
        token,
        createdAt,
        lastActivity,
        timeoutMinutes,
        isActive,
      ];
}