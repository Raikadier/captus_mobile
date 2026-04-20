enum NotificationType { task, group, course, ai, system }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? deepLink;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
    this.deepLink,
  });

  static List<AppNotification> get mockList => [
        AppNotification(
          id: 'n1',
          type: NotificationType.task,
          title: 'Entrega en 2 horas',
          body: 'Estructuras de Datos — Taller Árboles Binarios vence hoy a las 11 PM.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          deepLink: '/tasks/1',
        ),
        AppNotification(
          id: 'n2',
          type: NotificationType.ai,
          title: 'Captus IA tiene una sugerencia',
          body: 'Tienes 3 entregas esta semana. ¿Planificamos tu semana?',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          deepLink: '/ai',
        ),
        AppNotification(
          id: 'n3',
          type: NotificationType.group,
          title: 'Nueva tarea en Grupo Proyecto Final',
          body: 'Harold Flórez creó: "Revisar mockups de interfaz"',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          deepLink: '/groups/g1',
        ),
        AppNotification(
          id: 'n4',
          type: NotificationType.course,
          title: 'Nueva actividad en Cálculo II',
          body: 'Prof. Martínez publicó: "Taller Integrales — entrega el viernes"',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          deepLink: '/courses/c2',
        ),
      ];
}
