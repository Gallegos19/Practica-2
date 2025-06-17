import 'dart:convert';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.nombre,
    required super.correoElectronico,
    required super.edad,
    required super.nivelEducativo,
    required super.progresoActividades,
    required super.ubicacionGeografica,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      nombre: json['nombre'] ?? '',
      correoElectronico: json['correoElectronico'] ?? '',
      edad: json['edad'] ?? 0,
      nivelEducativo: json['nivelEducativo'] ?? '',
      progresoActividades: Map<String, double>.from(json['progresoActividades'] ?? {}),
      ubicacionGeografica: json['ubicacionGeografica'] ?? '',
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      nombre: entity.nombre,
      correoElectronico: entity.correoElectronico,
      edad: entity.edad,
      nivelEducativo: entity.nivelEducativo,
      progresoActividades: entity.progresoActividades,
      ubicacionGeografica: entity.ubicacionGeografica,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correoElectronico': correoElectronico,
      'edad': edad,
      'nivelEducativo': nivelEducativo,
      'progresoActividades': progresoActividades,
      'ubicacionGeografica': ubicacionGeografica,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory UserProfileModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserProfileModel.fromJson(json);
  }
}
