import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() =>
      _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<TaskModel> _taskResults(List<TaskModel> allTasks) =>
      _query.isEmpty
          ? []
          : allTasks
              .where((t) =>
                  t.title.toLowerCase().contains(_query.toLowerCase()))
              .toList();

  List<CourseModel> _courseResults(List<CourseModel> allCourses) =>
      _query.isEmpty
          ? []
          : allCourses
              .where((c) =>
                  c.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final allTasks =
        ref.watch(tasksNotifierProvider).asData?.value ?? [];
    final allCourses =
        ref.watch(coursesProvider).asData?.value ?? [];

    final tasks = _taskResults(allTasks);
    final courses = _courseResults(allCourses);
    final hasResults = tasks.isNotEmpty || courses.isNotEmpty;

    return Scaffold(
      restorationId: 'global_search_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Buscar tareas, materias, grupos...',
            hintStyle: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: AppColors.textDisabled),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Cerrar',
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? const _RecentSearches()
          : hasResults
              ? _SearchResults(tasks: tasks, courses: courses)
              : _NoResults(query: _query),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const recents = ['Cálculo II', 'Estructuras de Datos', 'Parcial'];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s4),
      children: [
        Text(
          'BÚSQUEDAS RECIENTES',
          style: tt.labelMedium!.copyWith(
              color: AppColors.textSecondary, letterSpacing: 0.8),
        ),
        const SizedBox(height: AppSpacing.s3),
        ...recents.map((r) => ListTile(
              leading: const Icon(Icons.history_rounded,
                  color: AppColors.textSecondary),
              title: Text(r, style: tt.bodyMedium),
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<CourseModel> courses;

  const _SearchResults({required this.tasks, required this.courses});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s4),
      children: [
        if (tasks.isNotEmpty) ...[
          Text(
            'TAREAS',
            style: tt.labelMedium!.copyWith(
                color: AppColors.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: AppSpacing.s2),
          ...tasks.map((t) => ListTile(
                leading: const Icon(
                    Icons.check_box_outline_blank_rounded,
                    color: AppColors.primary),
                title: Text(t.title, style: tt.bodyMedium),
                subtitle: Text(t.courseName ?? '',
                    style: tt.bodySmall),
                dense: true,
                onTap: () => context.push('/tasks/${t.id}'),
              )),
        ],
        if (courses.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s4),
          Text(
            'MATERIAS',
            style: tt.labelMedium!.copyWith(
                color: AppColors.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: AppSpacing.s2),
          ...courses.map((c) => ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.courseColor(c.colorIndex)
                        .withAlpha(AppAlpha.a15),
                    borderRadius: BorderRadius.circular(AppRadius.r2),
                  ),
                  child: Center(
                    child: Text(
                      c.name[0],
                      style: tt.labelLarge!.copyWith(
                          color:
                              AppColors.courseColor(c.colorIndex)),
                    ),
                  ),
                ),
                title: Text(c.name, style: tt.bodyMedium),
                subtitle: Text(c.code, style: tt.bodySmall),
                dense: true,
                onTap: () => context.push('/courses/${c.id}'),
              )),
        ],
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Sin resultados para "$query"',
              style: tt.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              '¿Quieres preguntarle a Captus IA?',
              style: tt.bodyMedium!
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s6),
            OutlinedButton.icon(
              onPressed: () => context.push('/ai'),
              icon: const Text('🤖',
                  style: TextStyle(fontSize: 16)),
              label: const Text('Preguntar al asistente'),
            ),
          ],
        ),
      ),
    );
  }
}
