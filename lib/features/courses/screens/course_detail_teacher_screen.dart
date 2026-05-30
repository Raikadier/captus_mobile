import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../models/course.dart';
import '../../../shared/widgets/captus_fab.dart';

class CourseDetailTeacherScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailTeacherScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailTeacherScreen> createState() =>
      _CourseDetailTeacherScreenState();
}

class _CourseDetailTeacherScreenState
    extends ConsumerState<CourseDetailTeacherScreen>
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

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r8)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.r1),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
              title: Text('Editar curso',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.archive_outlined, color: AppColors.warning),
              title: Text('Archivar curso',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warning)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseByIdProvider(widget.courseId));

    return courseAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text('No se pudo cargar el curso',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ),
      ),
      data: (course) {
        if (course == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text('Curso no encontrado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ),
          );
        }
        return _buildBody(context, course);
      },
    );
  }

  Widget _buildBody(BuildContext context, CourseModel course) {
    final color = AppColors.courseColor(course.colorIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textOnPrimary),
                onPressed: () => _showMenu(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withAlpha(AppAlpha.a70)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(AppSpacing.s4, 80, AppSpacing.s4, AppSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      course.name,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      course.code.isNotEmpty ? course.code : 'Sin código',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                  controller: _tabController,
                  labelColor: color,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: color,
                  indicatorWeight: 2,
                  labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13),
                  unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
                  tabs: const [
                    Tab(text: 'Actividades'),
                    Tab(text: 'Estudiantes'),
                    Tab(text: 'Estadísticas'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ActivitiesTeacherTab(course: course, color: color),
            const _StudentsTab(),
            _StatsTab(course: course, color: color),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index != 0) return const SizedBox.shrink();
          return CaptusFab(
            onPressed: () => context
                .push('/teacher/courses/${course.id}/activity/create'),
            icon: Icons.add_rounded,
            tooltip: 'Nueva actividad',
          );
        },
      ),
    );
  }
}

class _ActivitiesTeacherTab extends StatelessWidget {
  final CourseModel course;
  final Color color;

  const _ActivitiesTeacherTab({required this.course, required this.color});

  @override
  Widget build(BuildContext context) {
    if (course.activities.isEmpty) {
      return Center(
        child: Text('Sin actividades.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s4),
      itemCount: course.activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s2 + 2),
      itemBuilder: (context, index) {
        final activity = course.activities[index];
        final daysLeft = activity.dueDate.difference(DateTime.now()).inDays;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r6),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(AppAlpha.a10),
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
                child: Icon(Icons.assignment_outlined, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                    ),
                    Text(
                      '${activity.type} · ${daysLeft < 0 ? 'Vencida' : 'Vence en $daysLeft días'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: daysLeft < 0
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.textDisabled, size: 18),
                onPressed: () => context.push(
                    '/teacher/courses/${course.id}/activity/${activity.id}/edit'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StudentsTab extends StatelessWidget {
  const _StudentsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Lista de estudiantes próximamente.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final CourseModel course;
  final Color color;

  const _StatsTab({required this.course, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s4),
      children: [
        _StatCard(
          title: 'Promedio del grupo',
          value: '3.8',
          subtitle: 'Sobre 5.0',
          icon: Icons.grade_outlined,
          color: color,
        ),
        const SizedBox(height: AppSpacing.s3),
        _StatCard(
          title: 'Tasa de entrega',
          value: '84%',
          subtitle: '${(5 * 0.84).round()} de 5 actividades',
          icon: Icons.assignment_turned_in_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.s3),
        _StatCard(
          title: 'Estudiantes en riesgo',
          value: '1',
          subtitle: 'Progreso < 40%',
          icon: Icons.warning_amber_outlined,
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r6),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(AppAlpha.a10),
              borderRadius: BorderRadius.circular(AppRadius.r5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
