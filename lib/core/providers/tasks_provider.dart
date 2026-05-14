import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';
import 'auth_provider.dart';
import '../../features/statistics/providers/user_statistics_provider.dart';

class TasksService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<TaskModel>> fetchAll(String userId) async {
    final tasksResponse = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('due_date', ascending: true, nullsFirst: true);

    final categoriesResponse = await _client
        .from('categories')
        .select('id, name')
        .eq('user_id', userId);

    final categoriesMap = <int, String>{};
    for (final cat in categoriesResponse) {
      categoriesMap[cat['id'] as int] = cat['name'] as String;
    }

    final tasks = (tasksResponse as List)
        .map((json) {
          final task = TaskModel.fromJson(json as Map<String, dynamic>);
          final catId = task.categoryId;
          final taskMap = task.toJson();
          taskMap['category_name'] = catId != null ? categoriesMap[catId] : null;
          return TaskModel.fromJson(taskMap);
        })
        .toList();

    for (int i = 0; i < tasks.length; i++) {
      final subtasks = await _fetchSubtasks(tasks[i].id!);
      final taskMap = tasks[i].toJson();
      taskMap['subtasks'] = subtasks.map((s) => s.toJson()).toList();
      tasks[i] = TaskModel.fromJson(taskMap);
    }

    return tasks;
  }

  Future<List<SubTask>> _fetchSubtasks(int taskId) async {
    final response = await _client
        .from('subTask')
        .select()
        .eq('id_Task', taskId);

    return (response as List)
        .map((json) => SubTask.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel?> fetchById(int taskId) async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('id', taskId)
        .maybeSingle();

    if (response == null) return null;

    final subtasks = await _fetchSubtasks(taskId);
    final taskMap = Map<String, dynamic>.from(response);
    taskMap['subtasks'] = subtasks;

    return TaskModel.fromJson(taskMap);
  }

  Future<TaskModel> create({
    required String title,
    String? description,
    required int priorityId,
    required DateTime dueDate,
    required String userId,
    int? categoryId,
    int? parentTaskId,
    List<String>? subtaskTitles,
  }) async {
    final now = DateTime.now().toIso8601String();

    final taskData = {
      'title': title,
      'description': description,
      'priority_id': priorityId,
      'due_date': dueDate.toIso8601String(),
      'user_id': userId,
      'category_id': categoryId,
      'parent_task_id': parentTaskId,
      'created_at': now,
      'updated_at': now,
      'completed': false,
    };

    final response = await _client
        .from('tasks')
        .insert(taskData)
        .select()
        .single();

    final taskId = response['id'] as int;

    if (subtaskTitles != null && subtaskTitles.isNotEmpty) {
      for (final title in subtaskTitles) {
        await _client.from('subTask').insert({
          'id_Task': taskId,
          'title': title,
          'state': false,
          'id_Category': categoryId ?? 1,
          'id_Priority': priorityId,
          'endDate': dueDate.toIso8601String(),
        });
      }
    }

    return (await fetchById(taskId))!;
  }

  Future<TaskModel?> update(int taskId, Map<String, dynamic> updates) async {
    final updateData = Map<String, dynamic>.from(updates);
    updateData['updated_at'] = DateTime.now().toIso8601String();

    if (updateData.containsKey('completed')) {
      updateData['completed'] = updateData['completed'] == true;
    }

    await _client
        .from('tasks')
        .update(updateData)
        .eq('id', taskId);

    return fetchById(taskId);
  }

  Future<void> delete(int taskId) async {
    await _client.from('subTask').delete().eq('id_Task', taskId);
    await _client.from('tasks').delete().eq('id', taskId);
  }

  Future<void> completeWithSubtasks(int taskId) async {
    await _client.from('tasks').update({
      'completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);

    await _client.from('subTask').update({
      'state': true,
    }).eq('id_Task', taskId);
  }

  Future<void> completeSubtask(int subtaskId, bool completed) async {
    await _client.from('subTask').update({
      'state': completed,
    }).eq('id_SubTask', subtaskId);
  }

  Future<List<SubTask>> fetchSubtasksForTask(int taskId) async {
    return _fetchSubtasks(taskId);
  }

  Future<void> createSubtask(int taskId, String title) async {
    await _client.from('subTask').insert({
      'id_Task': taskId,
      'title': title,
      'state': false,
    });
  }

  Future<void> deleteSubtask(int subtaskId) async {
    await _client.from('subTask').delete().eq('id_SubTask', subtaskId);
  }
}

final tasksServiceProvider = Provider<TasksService>((ref) => TasksService());

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Future.value([]);
    return ref.read(tasksServiceProvider).fetchAll(user.id);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tasksServiceProvider).fetchAll(user.id),
    );
  }

  Future<TaskModel?> create({
    required String title,
    String? description,
    required int priorityId,
    required DateTime dueDate,
    int? categoryId,
    int? parentTaskId,
    List<String>? subtaskTitles,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    try {
      final task = await ref.read(tasksServiceProvider).create(
        title: title,
        description: description,
        priorityId: priorityId,
        dueDate: dueDate,
        userId: user.id,
        categoryId: categoryId,
        parentTaskId: parentTaskId,
        subtaskTitles: subtaskTitles,
      );

      state = state.whenData((tasks) => [task, ...tasks]);
      _updateStatisticsOnCreate();
      return task;
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  void _updateStatisticsOnCreate() {
    Future.microtask(() {
      try {
        ref.read(userStatisticsProvider.notifier).onTaskCreated();
      } catch (_) {}
    });
  }

  Future<void> updateTask(int taskId, Map<String, dynamic> updates) async {
    try {
      final updated = await ref.read(tasksServiceProvider).update(taskId, updates);
      if (updated != null) {
        state = state.whenData(
          (tasks) => tasks.map((t) => t.id == taskId ? updated : t).toList(),
        );
      }
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> delete(int taskId) async {
    state = state.whenData(
      (tasks) => tasks.where((t) => t.id != taskId).toList(),
    );
    try {
      await ref.read(tasksServiceProvider).delete(taskId);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> completeWithSubtasks(int taskId) async {
    state = state.whenData((tasks) {
      return tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(
            completed: true,
            status: TaskStatus.completed,
            subtasks: t.subtasks.map((s) => s.copyWith(isCompleted: true)).toList(),
          );
        }
        return t;
      }).toList();
    });

    try {
      await ref.read(tasksServiceProvider).completeWithSubtasks(taskId);
      _updateStatisticsOnComplete();
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  void _updateStatisticsOnComplete() {
    Future.microtask(() {
      try {
        ref.read(userStatisticsProvider.notifier).onTaskCompleted();
      } catch (_) {}
    });
  }

  Future<void> completeSubtask(int taskId, int subtaskId, bool completed) async {
    state = state.whenData((tasks) {
      return tasks.map((t) {
        if (t.id == taskId) {
          final updatedSubtasks = t.subtasks.map((s) {
            if (s.id == subtaskId.toString()) {
              return s.copyWith(isCompleted: completed);
            }
            return s;
          }).toList();
          return t.copyWith(subtasks: updatedSubtasks);
        }
        return t;
      }).toList();
    });

    try {
      await ref.read(tasksServiceProvider).completeSubtask(subtaskId, completed);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }
}

final tasksNotifierProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

final filteredTasksProvider =
    Provider.autoDispose<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksNotifierProvider);
  final filters = ref.watch(taskFiltersProvider);

  return tasksAsync.whenData((tasks) {
    var filtered = tasks.where((t) => t.parentTaskId == null).toList();

    // Filtro por búsqueda
    if (filters.searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
        t.title.toLowerCase().contains(filters.searchQuery.toLowerCase()) ||
        (t.description?.toLowerCase().contains(filters.searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Filtro por prioridad
    if (filters.priorityFilter != null) {
      filtered = filtered.where((t) {
        final priorityValue = t.priority == TaskPriority.high ? 1 :
                              t.priority == TaskPriority.medium ? 2 : 3;
        return priorityValue == filters.priorityFilter;
      }).toList();
    }

    // Filtro por categoría
    if (filters.categoryFilter != null) {
      filtered = filtered.where((t) => t.categoryId == filters.categoryFilter).toList();
    }

    // Filtro por fecha
    if (filters.dateFilter != null) {
      filtered = filtered.where((t) {
        if (t.dueDate == null) return false;
        return t.dueDate!.year == filters.dateFilter!.year &&
               t.dueDate!.month == filters.dateFilter!.month &&
               t.dueDate!.day == filters.dateFilter!.day;
      }).toList();
    }

    // Filtro por estado
    if (filters.estadoFilter != null) {
      switch (filters.estadoFilter) {
        case 'pendientes':
          filtered = filtered.where((t) => !t.completed && !t.isOverdue).toList();
          break;
        case 'completadas':
          filtered = filtered.where((t) => t.completed).toList();
          break;
        case 'vencidas':
          filtered = filtered.where((t) => t.isOverdue && !t.completed).toList();
          break;
      }
    }

    // Ordenar: primero pendientes por fecha cercana, después completadas/vencidas
    filtered.sort((a, b) {
      final aCompleted = a.completed || a.isOverdue;
      final bCompleted = b.completed || b.isOverdue;
      
      if (!aCompleted && !bCompleted) {
        // Ambas pendientes - ordenar por fecha
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      }
      
      if (!aCompleted) return -1;
      if (!bCompleted) return 1;
      
      // Ambas completadas/vencidas - ordenar por fecha
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return filtered;
  });
});

class TaskFilters {
  final String searchQuery;
  final int? priorityFilter;
  final int? categoryFilter;
  final DateTime? dateFilter;
  final String? estadoFilter; // 'pendientes', 'completadas', 'vencidas'

  const TaskFilters({
    this.searchQuery = '',
    this.priorityFilter,
    this.categoryFilter,
    this.dateFilter,
    this.estadoFilter,
  });

  TaskFilters copyWith({
    String? searchQuery,
    int? priorityFilter,
    int? categoryFilter,
    DateTime? dateFilter,
    String? estadoFilter,
    bool clearPriority = false,
    bool clearCategory = false,
    bool clearDate = false,
    bool clearEstado = false,
  }) {
    return TaskFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      priorityFilter: clearPriority ? null : (priorityFilter ?? this.priorityFilter),
      categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      dateFilter: clearDate ? null : (dateFilter ?? this.dateFilter),
      estadoFilter: clearEstado ? null : (estadoFilter ?? this.estadoFilter),
    );
  }
}

class TaskFiltersNotifier extends Notifier<TaskFilters> {
  @override
  TaskFilters build() => const TaskFilters();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setPriorityFilter(int? priority) {
    if (priority == null) {
      state = state.copyWith(clearPriority: true);
    } else {
      state = state.copyWith(priorityFilter: priority);
    }
  }

  void setCategoryFilter(int? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryFilter: category);
    }
  }

  void setDateFilter(DateTime? date) {
    if (date == null) {
      state = state.copyWith(clearDate: true);
    } else {
      state = state.copyWith(dateFilter: date);
    }
  }

  void setEstadoFilter(String? estado) {
    if (estado == null) {
      state = state.copyWith(clearEstado: true);
    } else {
      state = state.copyWith(estadoFilter: estado);
    }
  }

  void clearAll() {
    state = const TaskFilters();
  }
}

final taskFiltersProvider = NotifierProvider<TaskFiltersNotifier, TaskFilters>(
  TaskFiltersNotifier.new,
);

final searchQueryProvider = Provider<String>((ref) => ref.watch(taskFiltersProvider).searchQuery);
final priorityFilterProvider = Provider<int?>((ref) => ref.watch(taskFiltersProvider).priorityFilter);
final categoryFilterProvider = Provider<int?>((ref) => ref.watch(taskFiltersProvider).categoryFilter);
final dateFilterProvider = Provider<DateTime?>((ref) => ref.watch(taskFiltersProvider).dateFilter);

final pendingTasksProvider = Provider.autoDispose<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksNotifierProvider);
  return tasksAsync.whenData(
    (tasks) => tasks.where((t) => !t.completed && t.parentTaskId == null).toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      }),
  );
});

final overdueTasksProvider = Provider.autoDispose<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksNotifierProvider);
  return tasksAsync.whenData(
    (tasks) => tasks.where((t) => t.isOverdue && t.parentTaskId == null).toList(),
  );
});

final completedTasksProvider = Provider.autoDispose<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksNotifierProvider);
  return tasksAsync.whenData(
    (tasks) => tasks.where((t) => t.completed && t.parentTaskId == null).toList(),
  );
});

final taskByIdProvider = Provider.family<TaskModel?, int>((ref, taskId) {
  final tasksAsync = ref.watch(tasksNotifierProvider);
  return tasksAsync.whenOrNull(
    data: (tasks) {
      try {
        return tasks.firstWhere((t) => t.id == taskId);
      } catch (_) {
        return null;
      }
    },
  );
});