import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio para notificaciones locales
/// 
/// Tipos de notificaciones:
/// - Recordatorios de tareas
/// - Recordatorios de entrega de cursos
/// - Recordatorios de reuniones de grupos
/// - Alertas de actividad
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _instance;
  }

  /// Inicializar notificaciones locales
  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings iOSSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      debugPrint('✅ Local notifications initialized');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Maneja cuando el usuario hace clic en una notificación
  void _handleNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Aquí puedes navegar o ejecutar acciones basadas en el payload
  }

  /// Mostrar notificación simple inmediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'captus_channel',
        'Captus Notifications',
        channelDescription: 'Notificaciones de Captus',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iOSDetails =
          DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('✅ Notification shown: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Programar notificación en un momento específico
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'captus_channel',
        'Captus Notifications',
        channelDescription: 'Notificaciones de Captus',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iOSDetails =
          DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('✅ Notification scheduled: $title');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Recordatorio de tarea próxima a vencer
  /// Se ejecuta 1 hora antes de la fecha de entrega
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    try {
      final reminderTime = dueDate.subtract(const Duration(hours: 1));
      
      if (reminderTime.isBefore(DateTime.now())) {
        // Si ya pasó la hora de recordatorio, mostrar inmediata
        await showNotification(
          id: taskId.hashCode,
          title: '⏰ Recordatorio de Tarea',
          body: '$taskTitle vence hoy',
          payload: taskId,
        );
      } else {
        await scheduleNotification(
          id: taskId.hashCode,
          title: '⏰ Recordatorio de Tarea',
          body: '$taskTitle vence en 1 hora',
          scheduledDate: reminderTime,
          payload: taskId,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling task reminder: $e');
    }
  }

  /// Recordatorio para asistencia a curso
  /// Se ejecuta 30 minutos antes de la hora de inicio
  Future<void> scheduleCourseAttendanceReminder({
    required String courseId,
    required String courseName,
    required DateTime startTime,
  }) async {
    try {
      final reminderTime = startTime.subtract(const Duration(minutes: 30));
      
      await scheduleNotification(
        id: courseId.hashCode,
        title: '📚 Clase Próxima',
        body: '$courseName inicia en 30 minutos',
        scheduledDate: reminderTime,
        payload: courseId,
      );
    } catch (e) {
      debugPrint('Error scheduling attendance reminder: $e');
    }
  }

  /// Alerta inmediata de logro desbloqueado
  Future<void> showAchievementNotification({
    required String title,
    required String description,
  }) async {
    try {
      await showNotification(
        id: DateTime.now().millisecond,
        title: '🏆 Logro Desbloqueado',
        body: '$title: $description',
      );
    } catch (e) {
      debugPrint('Error showing achievement: $e');
    }
  }

  /// Notificación de nuevo mensaje en grupo
  Future<void> showGroupMessageNotification({
    required String groupId,
    required String groupName,
    required String senderName,
    required String message,
  }) async {
    try {
      await showNotification(
        id: groupId.hashCode,
        title: '💬 Nuevo mensaje en $groupName',
        body: '$senderName: $message',
        payload: groupId,
      );
    } catch (e) {
      debugPrint('Error showing group message: $e');
    }
  }

  /// Cancelar una notificación programada
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('✅ Notification cancelled: $id');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}
