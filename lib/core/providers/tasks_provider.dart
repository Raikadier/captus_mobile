import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../../models/task.dart';

class TasksService {
  Future<List<TaskModel>> fetchAll() async {
    final tasks = LocalStorageService.tasks;
    return tasks.map((t) => TaskModel.fromJson(t)).toList();
  }

  Future<TaskModel> create(Map<String, dynamic> payload) async {
    final task = TaskModel.fromJson(payload);
    await LocalStorageService.addTask(payload);
    return task;
  }

  Future<void> complete(String taskId) async {
    final tasks = LocalStorageService.tasks;
    final index = tasks.indexWhere((t) => t['id'] == taskId);
    if (index != -1) {
      tasks[index]['completed'] = true;
      await LocalStorageService.setList(LocalStorageService.tasksKey, tasks);
    }
  }

  Future<void> delete(String taskId) async {
    await LocalStorageService.deleteTask(taskId);
  }

  Future<TaskModel?> updateTask(
      String taskId, Map<String, dynamic> updates) async {
    final tasks = LocalStorageService.tasks;
    final index = tasks.indexWhere((t) => t['id'] == taskId);
    if (index != -1) {
      tasks[index] = {...tasks[index], ...updates};
      await LocalStorageService.setList(LocalStorageService.tasksKey, tasks);
      return TaskModel.fromJson(tasks[index]);
    }
    return null;
  }
}

final tasksServiceProvider = Provider<TasksService>(
  (ref) => TasksService(),
);

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
    state =
        await AsyncValue.guard(() => ref.read(tasksServiceProvider).fetchAll());
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
