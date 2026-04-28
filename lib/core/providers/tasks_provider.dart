import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import 'auth_provider.dart';
import '../../models/task.dart';

class TasksService {
  final _uuid = Uuid();

  Future<List<TaskModel>> fetchAll(String userId) async {
    final rawTasks = await DatabaseService.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dueDate ASC',
    );

    List<TaskModel> tasks = [];
    for (final raw in rawTasks) {
      final subtasksRaw = await DatabaseService.query(
        'subtasks',
        where: 'taskId = ?',
        whereArgs: [raw['id']],
      );

      final taskMap = Map<String, dynamic>.from(raw);
      taskMap['subTasks'] = subtasksRaw;
      taskMap['completed'] = raw['completed'] == 1;

      tasks.add(TaskModel.fromJson(taskMap));
    }
    return tasks;
  }

  Future<TaskModel> create(Map<String, dynamic> payload) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    final taskData = {
      'id': id,
      'title': payload['title'],
      'description': payload['description'],
      'priority': payload['priority']?.toString(),
      'status': 'pending',
      'dueDate': payload['dueDate'],
      'courseId': payload['courseId'],
      'subjectName': payload['subjectName'],
      'createdAt': now,
      'completed': 0,
      'userId': payload['userId'],
    };

    await DatabaseService.insert('tasks', taskData);

    if (payload['subTasks'] != null) {
      for (final st in (payload['subTasks'] as List)) {
        await DatabaseService.insert('subtasks', {
          'id': _uuid.v4(),
          'taskId': id,
          'title': st['title'],
          'completed': 0,
        });
      }
    }

    final saved = await fetchById(id);
    return saved!;
  }

  Future<TaskModel?> fetchById(String id) async {
    final res = await DatabaseService.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (res.isEmpty) return null;

    final subtasksRaw = await DatabaseService.query(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [id],
    );

    final taskMap = Map<String, dynamic>.from(res.first);
    taskMap['subTasks'] = subtasksRaw;
    taskMap['completed'] = res.first['completed'] == 1;

    return TaskModel.fromJson(taskMap);
  }

  Future<void> complete(String taskId) async {
    await DatabaseService.update(
      'tasks',
      {'completed': 1, 'status': 'completed'},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> delete(String taskId) async {
    await DatabaseService.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
    await DatabaseService.delete('subtasks',
        where: 'taskId = ?', whereArgs: [taskId]);
  }

  Future<TaskModel?> updateTask(
      String taskId, Map<String, dynamic> updates) async {
    final data = Map<String, dynamic>.from(updates);
    if (data.containsKey('completed')) {
      data['completed'] = data['completed'] == true ? 1 : 0;
    }
    if (data.containsKey('subTasks')) {
      data.remove('subTasks');
    }

    await DatabaseService.update(
      'tasks',
      data,
      where: 'id = ?',
      whereArgs: [taskId],
    );
    return fetchById(taskId);
  }
}

final tasksServiceProvider = Provider<TasksService>(
  (ref) => TasksService(),
);

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() {
    final user = ref.watch(currentUserProvider);
    return ref.read(tasksServiceProvider).fetchAll(user?.id ?? '');
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(tasksServiceProvider).fetchAll(user?.id ?? ''));
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

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      final updated =
          await ref.read(tasksServiceProvider).updateTask(taskId, updates);
      if (updated != null) {
        state = state.whenData(
          (tasks) => tasks.map((t) => t.id == taskId ? updated : t).toList(),
        );
      }
    } catch (_) {
      await refresh();
      rethrow;
    }
  }
}

final tasksNotifierProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

final pendingTasksProvider =
    Provider.autoDispose<AsyncValue<List<TaskModel>>>((ref) {
  return ref.watch(tasksNotifierProvider).whenData(
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
  return ref.watch(tasksNotifierProvider).whenData(
        (tasks) => tasks.where((t) => t.isOverdue).toList(),
      );
});
