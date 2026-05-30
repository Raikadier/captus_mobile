import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../models/course.dart';

class CourseDetailStudentScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailStudentScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailStudentScreen> createState() =>
      _CourseDetailStudentScreenState();
}

class _CourseDetailStudentScreenState
    extends ConsumerState<CourseDetailStudentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final courseAsync = ref.watch(courseByIdProvider(widget.courseId));

    return courseAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'No se pudo cargar el curso',
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
      data: (course) {
        if (course == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text(
                'Curso no encontrado',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return _CourseDetailBody(
          course: course,
          tabController: _tabController,
        );
      },
    );
  }
}

class _CourseDetailBody extends StatelessWidget {
  final CourseModel course;
  final TabController tabController;

  const _CourseDetailBody({
    required this.course,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = AppColors.courseColor(course.colorIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withAlpha(AppAlpha.a70)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(AppSpacing.s4, 80, AppSpacing.s4, AppSpacing.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.textOnPrimary.withAlpha(AppAlpha.a20),
                        borderRadius: BorderRadius.circular(AppRadius.r2),
                      ),
                      child: Text(
                        course.code,
                        style: tt.labelMedium?.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      course.name,
                      style: tt.headlineLarge?.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      course.teacherName,
                      style: tt.labelLarge?.copyWith(
                        fontSize: 13,
                        color: AppColors.textOnPrimary.withAlpha(AppAlpha.a80),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.background,
                child: TabBar(
                  controller: tabController,
                  labelColor: color,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: color,
                  indicatorWeight: 2,
                  labelStyle: tt.labelLarge?.copyWith(fontSize: 13),
                  unselectedLabelStyle: tt.bodySmall?.copyWith(fontSize: 13),
                  tabs: const [
                    Tab(text: 'Actividades'),
                    Tab(text: 'Recursos'),
                    Tab(text: 'Información'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: tabController,
          children: [
            _ActivitiesTab(course: course, color: color),
            _ResourcesTab(),
            _InfoTab(course: course),
          ],
        ),
      ),
    );
  }
}

class _ActivitiesTab extends StatelessWidget {
  final CourseModel course;
  final Color color;

  const _ActivitiesTab({required this.course, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (course.activities.isEmpty) {
      return Center(
        child: Text(
          'Sin actividades por ahora.',
          style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s4),
      itemCount: course.activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final activity = course.activities[index];
        return _ActivityTile(
          activity: activity,
          courseId: course.id,
          accentColor: color,
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  final String courseId;
  final Color accentColor;

  const _ActivityTile({
    required this.activity,
    required this.courseId,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    Color chipColor;
    String chipLabel;
    if (activity.isGraded) {
      chipColor = AppColors.primary;
      chipLabel = 'Calificada';
    } else if (activity.isSubmitted) {
      chipColor = AppColors.info;
      chipLabel = 'Entregada';
    } else {
      chipColor = AppColors.warning;
      chipLabel = 'Pendiente';
    }

    final daysLeft = activity.dueDate.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () => context.push('/courses/$courseId/activity/${activity.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r6),
          border: Border.all(color: AppColors.border.withAlpha(AppAlpha.a50)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withAlpha(AppAlpha.a10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _typeIcon(activity.type),
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: tt.titleMedium?.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    daysLeft < 0
                        ? 'Vencida'
                        : daysLeft == 0
                            ? 'Vence hoy'
                            : 'Vence en $daysLeft día${daysLeft == 1 ? '' : 's'}',
                    style: tt.bodySmall?.copyWith(
                      color: daysLeft < 0
                          ? AppColors.error
                          : daysLeft <= 1
                              ? AppColors.warning
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: AppSpacing.s1),
              decoration: BoxDecoration(
                color: chipColor.withAlpha(AppAlpha.a10),
                borderRadius: BorderRadius.circular(AppRadius.r3),
              ),
              child: Text(
                chipLabel,
                style: tt.labelMedium?.copyWith(color: chipColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Examen':
        return Icons.assignment;
      case 'Quiz':
        return Icons.quiz;
      case 'Proyecto':
        return Icons.folder_special;
      case 'Presentación':
        return Icons.co_present;
      default:
        return Icons.task_alt;
    }
  }
}

class _ResourcesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Text(
        'Sin recursos disponibles.',
        style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final CourseModel course;

  const _InfoTab({required this.course});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s4),
      children: [
        _InfoCard(
          icon: Icons.info_outline,
          title: 'Descripción',
          value: course.description ?? 'Sin descripción disponible.',
        ),
        const SizedBox(height: AppSpacing.s3),
        _InfoCard(
          icon: Icons.schedule,
          title: 'Horario',
          value: course.schedule ?? 'Sin horario registrado.',
        ),
        const SizedBox(height: AppSpacing.s3),
        _InfoCard(
          icon: Icons.person_outline,
          title: 'Docente',
          value: course.teacherName,
        ),
        const SizedBox(height: AppSpacing.s3),
        _InfoCard(
          icon: Icons.trending_up,
          title: 'Progreso general',
          value: '${(course.progress * 100).toInt()}% completado',
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  value,
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
