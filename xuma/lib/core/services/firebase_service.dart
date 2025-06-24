import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:xuma/core/services/security_service.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Inicializar Firebase
    await Firebase.initializeApp();

    // Solicitar permisos
    await requestPermission();

    // Configurar handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Obtener y mostrar token
    String? token = await getToken();
    print('🔥 FCM Token: $token');
  }

  static Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('🔥 User granted permission: ${settings.authorizationStatus}');
  }

  static Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    return token;
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('🔥 Subscribed to topic: $topic');
  }

  /// Maneja mensajes en primer plano
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('🔥 Foreground message received:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    
    // Verificar si es un mensaje de borrado de emergencia
    await _checkForEmergencyWipe(message);
  }

  /// Maneja cuando el usuario abre la app desde una notificación
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('🔥 Message opened app:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    
    // Verificar si es un mensaje de borrado de emergencia
    await _checkForEmergencyWipe(message);
  }

  /// Verifica si el mensaje es una orden de borrado de emergencia
  static Future<void> _checkForEmergencyWipe(RemoteMessage message) async {
    final title = message.notification?.title;
    final body = message.notification?.body;
    
    print('🔍 Verificando mensaje de emergencia...');
    print('   Title: "$title"');
    print('   Body: "$body"');
    
    if (SecurityService.isEmergencyWipeMessage(title, body)) {
      print('🚨 MENSAJE DE EMERGENCIA DETECTADO!');
      print('🚨 Iniciando borrado automático de datos sensibles...');
      
      await SecurityService.emergencyDataWipe();
      
      print('🚨 Borrado de emergencia completado');
    } else {
      print('✅ Mensaje normal, no es una orden de borrado');
    }
  }

  /// Obtiene información detallada del último mensaje
  static Map<String, String?> getMessageInfo(RemoteMessage message) {
    return {
      'messageId': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Handler para mensajes en background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  print('🔥 Background message received:');
  print('   Title: ${message.notification?.title}');
  print('   Body: ${message.notification?.body}');
  
  // Verificar si es un mensaje de borrado de emergencia
  final title = message.notification?.title;
  final body = message.notification?.body;
  
  if (SecurityService.isEmergencyWipeMessage(title, body)) {
    print('🚨 MENSAJE DE EMERGENCIA EN BACKGROUND!');
    print('🚨 Iniciando borrado automático de datos sensibles...');
    
    await SecurityService.emergencyDataWipe();
    
    print('🚨 Borrado de emergencia completado en background');
  }
}