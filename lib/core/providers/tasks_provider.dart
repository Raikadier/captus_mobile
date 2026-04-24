import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../../models/task.dart';

class TasksService {
  Future<List<TaskModel>> fetchAll() async {
    final res = await ApiClient.instance.get<Map<String, dynamic>>('/tasks');
    final raw = res.data is Map ? (res.data!['data'] as List? ?? []) : [];
    return raw
        .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> create(Map<String, dynamic> payload) async {
    final res =
        await ApiClient.instance.post<Map<String, dynamic>>('/tasks', data: payload);
    final body = res.data is Map ? res.data! : <String, dynamic>{};
    final taskJson = (body['data'] as Map<String, dynamic>?) ?? body;
    return TaskModel.fromJson(taskJson);
  }

  Future<void> complete(String taskId) async {
    await ApiClient.instance.put<void>('/tasks/$taskId/complete');
  }

  Future<void> delete(String taskId) async {
    await ApiClient.instance.delete<void>('/tasks/$taskId');
  }

  Future<TaskModel?> updateTask(
      String taskId, Map<String, dynamic> updates) async {
    final res = await ApiClient.instance
        .put<Map<String, dynamic>>('/tasks/$taskId', data: updates);
    final body = res.data is Map ? res.data! : <String, dynamic>{};
    final taskJson = (body['data'] as Map<String, dynamic>?) ?? body;
    return TaskModel.fromJson(taskJson);
  }
}

final tasksServiceProvider = Provider<TasksService>((_) => TasksService());

final tasksProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) {
  return ref.read(tasksServiceProvider).fetchAll();
});

final pendingTasksProvider =
    Provider.autoDispose<AsyncValue<List<TaskModel>>>((ref) {
  return ref.watch(tasksProvider).whenData(
        (tasks) => tasks.where((t) => !t.completed).toList()
          ..sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          }),
      );
});

final overdueTasksProvider =
    Provider.autoDispose<AsyncValue<List<TaskModel>>>((ref) {
  return ref.watch(tasksProvider).whenData(
        (tasks) => tasks.where((t) => t.isOverdue).toList(),
      );
});

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() {
    return ref.read(tasksServiceProvider).fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(tasksServiceProvider).fetchAll());
  }

  Future<void> complete(String taskId) async {
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
      await refresh();
      rethrow;
    }
  }

  Future<void> delete(String taskId) async {
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
