import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../shared/widgets/captus_fab.dart';
import '../../../shared/widgets/captus_pressable.dart';

class HomeDashboardTeacherScreen extends ConsumerWidget {
  const HomeDashboardTeacherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider);
    final coursesAsync = ref.watch(teacherCoursesProvider);

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';
    final dateStr =
        DateFormat("EEEE d 'de' MMMM", 'es').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ─────────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              titleSpacing: AppSpacing.s4,
              title: Row(
                children: [
                  CaptusPressable(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withAlpha(AppAlpha.a15),
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'D',
                        style: tt.headlineSmall!
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Captus',
                    style: tt.headlineMedium!
                        .copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s2, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(AppAlpha.a10),
                      borderRadius: BorderRadius.circular(AppRadius.r3),
                      border:
                          Border.all(color: AppColors.info.withAlpha(AppAlpha.a30)),
                    ),
                    child: Text(
                      'Docente',
                      style: tt.labelMedium!
                          .copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  color: AppColors.textPrimary,
                  tooltip: 'Buscar',
                  onPressed: () => context.push('/search'),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppColors.textPrimary,
                  onPressed: () => context.push('/notifications'),
                ),
              ],
            ),

            // ── Saludo ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s4, AppSpacing.s2,
                    AppSpacing.s4, AppSpacing.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, ${user?.name ?? 'Docente'}',
                      style: tt.displaySmall,
                    ),
                    Text(
                      dateStr,
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            // ── Métricas ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: coursesAsync.when(
                loading: () => const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
                data: (courses) {
                  final totalStudents = courses.fold<int>(
                      0, (sum, c) => sum + c.studentCount);
                  return Container(
                    margin: const EdgeInsets.fromLTRB(
                        AppSpacing.s4, 0, AppSpacing.s4, AppSpacing.s4),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.r6),
                      border: Border.all(
                          color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MetricCard(
                          value: '${courses.length}',
                          label: 'Cursos',
                          icon: Icons.menu_book_outlined,
                        ),
                        const _Divider(),
                        _MetricCard(
                          value: '$totalStudents',
                          label: 'Estudiantes',
                          icon: Icons.group_outlined,
                        ),
                        const _Divider(),
                        const _MetricCard(
                          value: '0',
                          label: 'Por revisar',
                          icon: Icons.assignment_outlined,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Mis Cursos ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.s1),
                        Text('Mis Cursos',
                            style: tt.titleMedium),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              context.push('/teacher/courses'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s2),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Ver todo'),
                        ),
                        const SizedBox(width: AppSpacing.s1),
                        _PillButton(
                          label: '+ Nuevo',
                          onTap: () =>
                              context.push('/teacher/courses/new'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    coursesAsync.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (_, __) => Text('Error al cargar cursos',
                          style: tt.bodySmall),
                      data: (courses) => courses.isEmpty
                          ? _EmptyState(
                              icon: Icons.school_outlined,
                              message: 'No tienes cursos aún',
                              subtitle:
                                  'Crea tu primer curso para comenzar',
                            )
                          : Column(
                              children: courses
                                  .take(3)
                                  .map((c) => _CourseRow(
                                        course: c,
                                        onTap: () => context.push(
                                            '/teacher/courses/${c.id}'),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Próximos Eventos ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.s1),
                        Text('Próximos Eventos',
                            style: tt.titleMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    const _EmptyState(
                      icon: Icons.event_outlined,
                      message: 'No hay eventos próximos',
                    ),
                  ],
                ),
              ),
            ),

            // ── Revisiones Pendientes ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.rate_review_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.s1),
                        Text('Revisiones Pendientes',
                            style: tt.titleMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    const _EmptyState(
                      icon: Icons.assignment_outlined,
                      message: 'No hay revisiones pendientes',
                    ),
                  ],
                ),
              ),
            ),

            // ── Herramientas IA ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s4, 0, AppSpacing.s4, AppSpacing.s3),
                child: CaptusPressable(
                  onTap: () => context.push('/ai/teacher-tools'),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.r6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withAlpha(AppAlpha.a15),
                            borderRadius: BorderRadius.circular(AppRadius.r5),
                          ),
                          child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.textOnPrimary,
                              size: 22),
                        ),
                        const SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Herramientas IA Docente',
                                style: tt.titleMedium!.copyWith(
                                    color: AppColors.textOnPrimary),
                              ),
                              Text(
                                'Genera planes, rúbricas y bancos de preguntas',
                                style: tt.bodySmall!.copyWith(
                                    color: AppColors.textOnPrimary
                                        .withAlpha(AppAlpha.a70)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppColors.textOnPrimary),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 120 + MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CaptusFab(
        onPressed: () => context.push('/ai'),
        icon: Icons.auto_awesome_rounded,
        tooltip: 'Captus IA',
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.s4, 0, AppSpacing.s4, AppSpacing.s3),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r6),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return CaptusPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: tt.labelLarge!.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  const _EmptyState(
      {required this.icon, required this.message, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: tt.bodySmall),
              if (subtitle != null)
                Text(subtitle!,
                    style: tt.bodySmall!
                        .copyWith(color: AppColors.textDisabled)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: AppSpacing.s1),
        Text(value, style: tt.displaySmall),
        Text(label, style: tt.labelSmall),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(width: 0.5, height: 40, color: AppColors.border);
  }
}

class _CourseRow extends StatelessWidget {
  final TeacherCourse course;
  final VoidCallback onTap;

  const _CourseRow({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = AppColors.courseColor(course.colorIndex);
    return CaptusPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s2),
        padding: const EdgeInsets.all(AppSpacing.s3),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.r1),
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: tt.titleSmall),
                  Text(
                    '${course.studentCount} estudiantes • ${course.inviteCode}',
                    style: tt.labelSmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
