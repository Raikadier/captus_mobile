import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/course.dart';

class CourseDetailStudentScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailStudentScreen({super.key, required this.courseId});

  @override
  State<CourseDetailStudentScreen> createState() =>
      _CourseDetailStudentScreenState();
}

class _CourseDetailStudentScreenState extends State<CourseDetailStudentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CourseModel _course;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _course = CourseModel.mockList.firstWhere(
      (c) => c.id == widget.courseId,
      orElse: () => CourseModel.mockList.first,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.courseColor(_course.colorIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                ),
                padding:
                    const EdgeInsets.fromLTRB(16, 80, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _course.code,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _course.name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _course.teacherName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
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
                  labelStyle: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle:
                      GoogleFonts.inter(fontSize: 13),
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
          controller: _tabController,
          children: [
            _ActivitiesTab(course: _course, color: color),
            _ResourcesTab(),
            _InfoTab(course: _course),
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
    if (course.activities.isEmpty) {
      return Center(
        child: Text(
          'Sin actividades por ahora.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
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
      onTap: () =>
          context.push('/courses/$courseId/activity/${activity.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _typeIcon(activity.type),
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    daysLeft < 0
                        ? 'Vencida'
                        : daysLeft == 0
                            ? 'Vence hoy'
                            : 'Vence en $daysLeft día${daysLeft == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
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
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                chipLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: chipColor,
                ),
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
    return Center(
      child: Text(
        'Sin recursos disponibles.',
        style: GoogleFonts.inter(color: AppColors.textSecondary),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final CourseModel course;

  const _InfoTab({required this.course});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          icon: Icons.info_outline,
          title: 'Descripción',
          value: course.description ?? 'Sin descripción disponible.',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.schedule,
          title: 'Horario',
          value: course.schedule ?? 'Sin horario registrado.',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.person_outline,
          title: 'Docente',
          value: course.teacherName,
        ),
        const SizedBox(height: 12),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
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
