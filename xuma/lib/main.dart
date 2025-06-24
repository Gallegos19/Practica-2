import 'package:flutter/material.dart';
import 'package:xuma/app/my_app.dart';
import 'package:xuma/core/services/firebase_service.dart';
import 'di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar notificaciones
  await FirebaseService.initialize();
  
  // Inicializar dependencias
  await di.init();
  
  runApp(const MyApp());
}