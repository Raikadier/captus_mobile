// ignore_for_file: subtype_of_sealed_class

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captus_mobile/models/task.dart';
import 'package:captus_mobile/core/providers/tasks_provider.dart';

void main() {
  group('TaskFilters', () {
    test('should create with defaults', () {
      const filters = TaskFilters();

      expect(filters.searchQuery, '');
      expect(filters.priorityFilter, null);
      expect(filters.categoryFilter, null);
      expect(filters.dateFilter, null);
      expect(filters.estadoFilter, null);
    });

    test('copyWith should update fields', () {
      const filters = TaskFilters();

      final updated = filters.copyWith(
        searchQuery: 'test',
        priorityFilter: 1,
        categoryFilter: 2,
        estadoFilter: 'pendientes',
      );

      expect(updated.searchQuery, 'test');
      expect(updated.priorityFilter, 1);
      expect(updated.categoryFilter, 2);
      expect(updated.estadoFilter, 'pendientes');
    });

    test('copyWith should clear priority with clearPriority flag', () {
      final filters = const TaskFilters(priorityFilter: 1);

      final cleared = filters.copyWith(clearPriority: true);

      expect(cleared.priorityFilter, null);
    });

    test('copyWith should clear category with clearCategory flag', () {
      final filters = const TaskFilters(categoryFilter: 5);

      final cleared = filters.copyWith(clearCategory: true);

      expect(cleared.categoryFilter, null);
    });

    test('copyWith should clear date with clearDate flag', () {
      final filters = TaskFilters(dateFilter: DateTime(2026, 5, 19));

      final cleared = filters.copyWith(clearDate: true);

      expect(cleared.dateFilter, null);
    });

    test('copyWith should clear estado with clearEstado flag', () {
      final filters = const TaskFilters(estadoFilter: 'completadas');

      final cleared = filters.copyWith(clearEstado: true);

      expect(cleared.estadoFilter, null);
    });

    test('copyWith should override priority when provided', () {
      final filters = const TaskFilters(priorityFilter: 1);

      final updated = filters.copyWith(priorityFilter: 2);

      expect(updated.priorityFilter, 2);
    });
  });

  group('TaskFiltersNotifier', () {
    test('should start with defaults', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final filters = container.read(taskFiltersProvider);

      expect(filters.searchQuery, '');
      expect(filters.priorityFilter, null);
      expect(filters.categoryFilter, null);
    });

    test('setSearchQuery should update search query', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      container.read(taskFiltersProvider.notifier).setSearchQuery('test');

      expect(container.read(taskFiltersProvider).searchQuery, 'test');
    });

    test('setPriorityFilter should update priority', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      container.read(taskFiltersProvider.notifier).setPriorityFilter(2);

      expect(container.read(taskFiltersProvider).priorityFilter, 2);
    });

    test('setPriorityFilter with null should clear priority', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      container.read(taskFiltersProvider.notifier).setPriorityFilter(1);
      container.read(taskFiltersProvider.notifier).setPriorityFilter(null);

      expect(container.read(taskFiltersProvider).priorityFilter, null);
    });

    test('setCategoryFilter should update category', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      container.read(taskFiltersProvider.notifier).setCategoryFilter(3);

      expect(container.read(taskFiltersProvider).categoryFilter, 3);
    });

    test('setDateFilter should update date', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final date = DateTime(2026, 6, 1);
      container.read(taskFiltersProvider.notifier).setDateFilter(date);

      expect(container.read(taskFiltersProvider).dateFilter, date);
    });

    test('setEstadoFilter should update estado', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      container.read(taskFiltersProvider.notifier).setEstadoFilter('completadas');

      expect(container.read(taskFiltersProvider).estadoFilter, 'completadas');
    });

    test('clearAll should reset to defaults', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      container.read(taskFiltersProvider.notifier).setSearchQuery('test');
      container.read(taskFiltersProvider.notifier).setPriorityFilter(1);
      container.read(taskFiltersProvider.notifier).setCategoryFilter(2);
      container.read(taskFiltersProvider.notifier).setEstadoFilter('pendientes');
      container.read(taskFiltersProvider.notifier).clearAll();

      final filters = container.read(taskFiltersProvider);
      expect(filters.searchQuery, '');
      expect(filters.priorityFilter, null);
      expect(filters.categoryFilter, null);
      expect(filters.dateFilter, null);
      expect(filters.estadoFilter, null);
    });
  });

  group('tasksNotifierProvider', () {
    test('should return empty list when no user', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final tasks = await container.read(tasksNotifierProvider.future);

      expect(tasks, isEmpty);
    });
  });

  group('searchQueryProvider', () {
    test('should derive search query from filters', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(searchQueryProvider), '');

      container.read(taskFiltersProvider.notifier).setSearchQuery('buscar');

      expect(container.read(searchQueryProvider), 'buscar');
    });
  });

  group('priorityFilterProvider', () {
    test('should derive priority filter from filters', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(priorityFilterProvider), null);

      container.read(taskFiltersProvider.notifier).setPriorityFilter(1);

      expect(container.read(priorityFilterProvider), 1);
    });
  });

  group('categoryFilterProvider', () {
    test('should derive category filter from filters', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(categoryFilterProvider), null);

      container.read(taskFiltersProvider.notifier).setCategoryFilter(5);

      expect(container.read(categoryFilterProvider), 5);
    });
  });

  group('dateFilterProvider', () {
    test('should derive date filter from filters', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(dateFilterProvider), null);

      final date = DateTime(2026, 6, 15);
      container.read(taskFiltersProvider.notifier).setDateFilter(date);

      expect(container.read(dateFilterProvider), date);
    });
  });

  group('overdueTasksProvider', () {
    test('should return AsyncLoading when no data', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final result = container.read(overdueTasksProvider);

      expect(result, isA<AsyncLoading<List<TaskModel>>>());
    });
  });

  group('completedTasksProvider', () {
    test('should return AsyncLoading when no data', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final result = container.read(completedTasksProvider);

      expect(result, isA<AsyncLoading<List<TaskModel>>>());
    });
  });

  group('pendingTasksProvider', () {
    test('should return AsyncLoading when no data', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final result = container.read(pendingTasksProvider);

      expect(result, isA<AsyncLoading<List<TaskModel>>>());
    });
  });
}
