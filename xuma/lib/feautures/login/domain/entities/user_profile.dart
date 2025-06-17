import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String nombre;
  final String correoElectronico;
  final int edad;
  final String nivelEducativo;
  final Map<String, double> progresoActividades;
  final String ubicacionGeografica;

  const UserProfile({
    required this.nombre,
    required this.correoElectronico,
    required this.edad,
    required this.nivelEducativo,
    required this.progresoActividades,
    required this.ubicacionGeografica,
  });

  UserProfile copyWith({
    String? nombre,
    String? correoElectronico,
    int? edad,
    String? nivelEducativo,
    Map<String, double>? progresoActividades,
    String? ubicacionGeografica,
  }) {
    return UserProfile(
      nombre: nombre ?? this.nombre,
      correoElectronico: correoElectronico ?? this.correoElectronico,
      edad: edad ?? this.edad,
      nivelEducativo: nivelEducativo ?? this.nivelEducativo,
      progresoActividades: progresoActividades ?? this.progresoActividades,
      ubicacionGeografica: ubicacionGeografica ?? this.ubicacionGeografica,
    );
  }

  @override
  List<Object?> get props => [
        nombre,
        correoElectronico,
        edad,
        nivelEducativo,
        progresoActividades,
        ubicacionGeografica,
      ];
}