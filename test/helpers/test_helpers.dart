// Shared test infrastructure for Captus Mobile.
//
// Usage:
//   await tester.pumpWidget(makeTestableWidget(child));
//   await tester.pumpWidget(makeTestableWidget(child, overrides: [...]));

// All imports MUST come first in Dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:captus_mobile/core/services/local_storage_service.dart';
import 'package:captus_mobile/core/theme/app_theme.dart';
import 'package:captus_mobile/core/providers/connectivity_provider.dart';
import 'package:captus_mobile/models/task.dart';

// ── Provider overrides ───────────────────────────────────────────────────────

/// Override isOnlineProvider to return [online].
Override connectivityOverride({bool online = true}) =>
    isOnlineProvider.overrideWith((ref) => online);

// ── Widget wrappers ──────────────────────────────────────────────────────────

/// Wraps [child] in the minimum shell required by most screens:
///   ProviderScope → MaterialApp → theme
Widget makeTestableWidget(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light,
      home: child,
    ),
  );
}

/// Like [makeTestableWidget] but wraps in a Scaffold — useful for widgets
/// that rely on Scaffold.of(context) (e.g. SnackBars, FABs).
Widget makeScaffoldWidget(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return makeTestableWidget(
    Scaffold(body: child),
    overrides: overrides,
  );
}

// ── setUp helpers ─────────────────────────────────────────────────────────────

/// Call in setUp() to initialise all env / storage stubs needed by providers.
Future<void> initTestEnvironment() async {
  dotenv.testLoad(mergeWith: {
    'API_BASE_URL': 'http://localhost:3000/api',
    'SUPABASE_URL': '',
    'SUPABASE_ANON_KEY': '',
  });
  SharedPreferences.setMockInitialValues({});
  await LocalStorageService.initialize();
}

// ── Task fixture helpers ──────────────────────────────────────────────────────

TaskModel makeTask({
  int id = 1,
  String title = 'Tarea de prueba',
  String? description,
  TaskPriority priority = TaskPriority.medium,
  TaskStatus status = TaskStatus.pending,
  DateTime? dueDate,
  bool completed = false,
  String? categoryName,
  List<SubTask> subtasks = const [],
}) =>
    TaskModel(
      id: id,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
      completed: completed,
      categoryName: categoryName,
      subtasks: subtasks,
      createdAt: DateTime(2026, 5, 1),
    );

TaskModel makeOverdueTask({
  int id = 10,
  String title = 'Tarea vencida',
}) =>
    makeTask(
      id: id,
      title: title,
      priority: TaskPriority.high,
      status: TaskStatus.overdue,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
    );

TaskModel makeCompletedTask({
  int id = 20,
  String title = 'Tarea completada',
}) =>
    makeTask(
      id: id,
      title: title,
      priority: TaskPriority.low,
      status: TaskStatus.completed,
      completed: true,
    );
