import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../../models/task.dart';

// ── Service ───────────────────────────────────────────────────────────────────

class TasksService {
  final ApiClient _api;
  TasksService(this._api);

  Future<List<TaskModel>> fetchAll() async {
    final res = await _api.get<Map<String, dynamic>>('/tasks');
    final data = res.data;
    if (data == null || data['success'] != true) return [];
    final list = (data['data'] as List?) ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(TaskModel.fromJson)
        .toList();
  }

  Future<TaskModel> fetchById(int id) async {
    final res = await _api.get<Map<String, dynamic>>('/tasks/$id');
    final data = res.data!;
    return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<TaskModel> create(Map<String, dynamic> payload) async {
    final res = await _api.post<Map<String, dynamic>>('/tasks', data: payload);
    final data = res.data!;
    return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> complete(String taskId) async {
    await _api.put<void>('/tasks/$taskId/complete');
  }

  Future<void> delete(String taskId) async {
    await _api.delete<void>('/tasks/$taskId');
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final tasksServiceProvider = Provider<TasksService>(
  (ref) => TasksService(ApiClient.instance),
);

/// Loads all tasks for the authenticated user.
final tasksProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) {
  return ref.read(tasksServiceProvider).fetchAll();
});

/// Pending tasks only (excludes completed, sorted by due date)
final pendingTasksProvider = Provider.autoDispose<AsyncValue<List<TaskModel>>>((ref) {
  return ref.watch(tasksProvider).whenData(
        (tasks) => tasks
            .where((t) => !t.completed)
            .toList()
          ..sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          }),
      );
});

/// Overdue tasks (for dashboard alert section)
final overdueTasksProvider = Provider.autoDispose<AsyncValue<List<TaskModel>>>((ref) {
  return ref.watch(tasksProvider).whenData(
        (tasks) => tasks.where((t) => t.isOverdue).toList(),
      );
});

// ── Notifier (optimistic updates) ────────────────────────────────────────────

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() {
    return ref.read(tasksServiceProvider).fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(tasksServiceProvider).fetchAll());
  }

  Future<void> complete(String taskId) async {
    // Optimistic update
    state = state.whenData(
      (tasks) => tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(completed: true, status: TaskStatus.completed);
        }
        return t;
      }).toList(),
    );
    try {
      await ref.read(tasksServiceProvider).complete(taskId);
    } catch (_) {
      // Revert on failure
      await refresh();
      rethrow;
    }
  }

  Future<void> delete(String taskId) async {
    // Optimistic update
    state = state.whenData(
      (tasks) => tasks.where((t) => t.id != taskId).toList(),
    );
    try {
      await ref.read(tasksServiceProvider).delete(taskId);
    } catch (_) {
      await refresh();
      rethrow;
    }
  }

  Future<TaskModel?> create(Map<String, dynamic> payload) async {
    try {
      final task = await ref.read(tasksServiceProvider).create(payload);
      state = state.whenData((tasks) => [task, ...tasks]);
      return task;
    } catch (_) {
      rethrow;
    }
  }
}

final tasksNotifierProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);
