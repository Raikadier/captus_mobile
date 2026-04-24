import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Servicio para notificaciones push mediante Firebase Cloud Messaging
/// 
/// Requisitos:
/// - Firebase configurado en el proyecto
/// - Token de FCM almacenado en backend para enviar mensajes
/// 
/// Tipos de notificaciones push:
/// - Recordatorios de cursos
/// - Notificaciones de grupo
/// - Anuncios importantes
/// - Recordatorios de entregas
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    return _instance;
  }

  /// Inicializar Firebase Messaging
  Future<void> initialize() async {
    try {
      // Solicitar permiso para notificaciones (iOS)
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Obtener token de FCM
      String? token = await _firebaseMessaging.getToken();
      debugPrint('✅ FCM Token: $token');

      // Escuchar notificaciones cuando la app está en foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Escuchar notificaciones cuando se hace clic en ellas
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Manejar mensaje de fondo (cuando app está cerrada)
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      debugPrint('✅ Firebase Messaging initialized');
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  /// Obtener el token FCM actual
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Manejar mensajes en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Foreground message received:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Mostrar notificación si es necesario
    if (message.notification != null) {
      // Aquí puedes llamar a LocalNotificationService
      // o mostrar un diálogo/snackbar personalizado
    }
  }

  /// Manejar cuando se abre la app desde una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📭 Message opened app:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Navegar a la pantalla correspondiente según los datos
    final messageData = message.data;
    if (messageData.containsKey('route')) {
      final route = messageData['route'];
      // Aquí ejecutarías navegación usando GoRouter
      // router.push(route);
    }
  }

  /// Manejador global de mensajes en background (debe ser top-level)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('🔔 Background message received:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
  }

  /// Suscribirse a un tema (para notificaciones masivas)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Desuscribirse de un tema
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  /// Suscribirse a notificaciones de un curso
  Future<void> subscribeToCourseNotifications(String courseId) async {
    try {
      await subscribeToTopic('course_$courseId');
    } catch (e) {
      debugPrint('Error subscribing to course: $e');
    }
  }

  /// Suscribirse a notificaciones de un grupo
  Future<void> subscribeToGroupNotifications(String groupId) async {
    try {
      await subscribeToTopic('group_$groupId');
    } catch (e) {
      debugPrint('Error subscribing to group: $e');
    }
  }

  /// Suscribirse a notificaciones globales
  Future<void> subscribeToGeneralNotifications() async {
    try {
      await subscribeToTopic('general');
    } catch (e) {
      debugPrint('Error subscribing to general: $e');
    }
  }

  /// Desuscribirse de notificaciones de un curso
  Future<void> unsubscribeFromCourseNotifications(String courseId) async {
    try {
      await unsubscribeFromTopic('course_$courseId');
    } catch (e) {
      debugPrint('Error unsubscribing from course: $e');
    }
  }

  /// Desuscribirse de notificaciones de un grupo
  Future<void> unsubscribeFromGroupNotifications(String groupId) async {
    try {
      await unsubscribeFromTopic('group_$groupId');
    } catch (e) {
      debugPrint('Error unsubscribing from group: $e');
    }
  }
}
