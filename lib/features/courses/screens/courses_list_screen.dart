import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../models/course.dart';
import '../../../shared/widgets/captus_fab.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/staggered_list.dart';
import '../../../shared/widgets/captus_pressable.dart';

class CoursesListScreen extends ConsumerWidget {
  const CoursesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      restorationId: 'courses_list_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mis Cursos',
          style: tt.headlineLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            tooltip: 'Buscar',
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.s3),
              Text(
                'No se pudo cargar los cursos',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s4),
              OutlinedButton(
                onPressed: () => ref.invalidate(coursesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (courses) => courses.isEmpty
            ? const EmptyState(
                icon: Icons.school_outlined,
                title: 'Sin cursos',
                subtitle: 'Aún no tienes cursos matriculados.',
                actionLabel: 'Agregar curso',
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(coursesProvider),
                child: StaggeredGridView.builder(
                  itemCount: courses.length,
                  staggerMs: 60,
                  durationMs: 250,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s4, AppSpacing.s4, AppSpacing.s4, 100),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.s3,
                    mainAxisSpacing: AppSpacing.s3,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    return _CourseCard(
                        course: courses[index], index: index);
                  },
                ),
              ),
      ),
      floatingActionButton: CaptusFab(
        onPressed: () => context.push('/join'),
        icon: Icons.add_rounded,
        tooltip: 'Unirse a un curso',
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final int index;

  const _CourseCard({required this.course, required this.index});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = AppColors.courseColor(course.colorIndex);

    return CaptusPressable(
      onTap: () => context.push('/courses/${course.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r7),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 8,
              color: color,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withAlpha(AppAlpha.a15),
                            borderRadius: BorderRadius.circular(AppRadius.r4),
                          ),
                          child: Icon(Icons.school, color: color, size: 20),
                        ),
                        const Spacer(),
                        if (course.pendingActivities > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.warning.withAlpha(AppAlpha.a15),
                              borderRadius: BorderRadius.circular(AppRadius.r3),
                            ),
                            child: Text(
                              '${course.pendingActivities}',
                              style: tt.labelMedium?.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s2 + 2),
                    Text(
                      course.name,
                      style: tt.labelLarge?.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      course.code,
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso',
                              style: tt.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${(course.progress * 100).toInt()}%',
                              style: tt.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s1),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.r1),
                          child: LinearProgressIndicator(
                            value: course.progress,
                            backgroundColor: AppColors.surface2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
