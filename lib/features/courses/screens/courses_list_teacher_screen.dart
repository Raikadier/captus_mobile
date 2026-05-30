import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../models/course.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/captus_pressable.dart';

class CoursesListTeacherScreen extends ConsumerWidget {
  const CoursesListTeacherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mis Cursos',
          style: tt.headlineLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onPressed: () {},
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
            ? EmptyState(
                icon: Icons.school_outlined,
                title: 'Sin cursos',
                subtitle: 'Crea tu primer curso para comenzar.',
                actionLabel: 'Crear curso',
                onAction: () => context.push('/teacher/courses/create'),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(coursesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s3),
                  itemBuilder: (context, index) {
                    return _TeacherCourseCard(course: courses[index]);
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/teacher/courses/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add),
        label: Text(
          'Nuevo curso',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _TeacherCourseCard extends StatelessWidget {
  final CourseModel course;

  const _TeacherCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = AppColors.courseColor(course.colorIndex);
    final pendingReviews = course.pendingActivities;

    return CaptusPressable(
      onTap: () => context.push('/teacher/courses/${course.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r7),
          border: Border.all(color: AppColors.border.withAlpha(AppAlpha.a40)),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.r7),
                  bottomLeft: Radius.circular(AppRadius.r7),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(AppAlpha.a15),
                            borderRadius: BorderRadius.circular(AppRadius.r2),
                          ),
                          child: Text(
                            course.code.isNotEmpty ? course.code : '—',
                            style: tt.labelMedium?.copyWith(color: color),
                          ),
                        ),
                        const Spacer(),
                        if (pendingReviews > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.warning.withAlpha(AppAlpha.a15),
                              borderRadius: BorderRadius.circular(AppRadius.r3),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pending_actions,
                                    size: 12, color: AppColors.warning),
                                const SizedBox(width: AppSpacing.s1),
                                Text(
                                  '$pendingReviews por revisar',
                                  style: tt.labelMedium?.copyWith(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s2),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      course.name,
                      style: tt.titleLarge?.copyWith(color: AppColors.textPrimary),
                    ),
                    if (course.description != null &&
                        course.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        course.description!,
                        style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.s3),
              child: Icon(Icons.chevron_right,
                  color: AppColors.textDisabled, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
