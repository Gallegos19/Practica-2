import 'dart:convert';
import 'package:xuma/feautures/auth/domain/entities/auth_session.dart';


class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.token,
    required super.createdAt,
    super.lastActivity,
    super.timeoutMinutes,
    super.isActive,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: json['token'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      lastActivity: json['lastActivity'] != null 
          ? DateTime.parse(json['lastActivity']) 
          : null,
      timeoutMinutes: json['timeoutMinutes'] ?? 15,
      isActive: json['isActive'] ?? true,
    );
  }

  factory AuthSessionModel.fromEntity(AuthSession entity) {
    return AuthSessionModel(
      token: entity.token,
      createdAt: entity.createdAt,
      lastActivity: entity.lastActivity,
      timeoutMinutes: entity.timeoutMinutes,
      isActive: entity.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity?.toIso8601String(),
      'timeoutMinutes': timeoutMinutes,
      'isActive': isActive,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory AuthSessionModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return AuthSessionModel.fromJson(json);
  }

  // Método para generar un nuevo token (simulado)
  static String generateToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 31) % 1000000;
    return 'token_${timestamp}_$random';
  }
}