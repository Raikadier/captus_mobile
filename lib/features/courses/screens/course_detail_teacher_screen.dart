import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/course.dart';

class CourseDetailTeacherScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailTeacherScreen({super.key, required this.courseId});

  @override
  State<CourseDetailTeacherScreen> createState() =>
      _CourseDetailTeacherScreenState();
}

class _CourseDetailTeacherScreenState extends State<CourseDetailTeacherScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CourseModel _course;

  static const _mockStudents = [
    _StudentData('s1', 'Ana Ramírez', 0.88, 'Parcial 2', true),
    _StudentData('s2', 'Carlos Pinto', 0.55, 'Taller Árboles', false),
    _StudentData('s3', 'Luisa Herrera', 0.92, 'Parcial 2', true),
    _StudentData('s4', 'Mauricio Soto', 0.34, 'Nada reciente', false),
    _StudentData('s5', 'Daniela Ríos', 0.75, 'Parcial 2', true),
  ];

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

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.textPrimary),
              title: Text('Editar curso',
                  style: GoogleFonts.inter(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined,
                  color: AppColors.warning),
              title: Text('Archivar curso',
                  style: GoogleFonts.inter(color: AppColors.warning)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.courseColor(_course.colorIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showMenu(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _course.name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_course.code} · ${_mockStudents.length} estudiantes',
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
            _ActivitiesTeacherTab(course: _course, color: color),
            _StudentsTab(students: _mockStudents),
            _StatsTab(course: _course, color: color),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index != 0) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => context.push(
                '/teacher/courses/${_course.id}/activity/create'),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.black),
          );
        },
      ),
    );
  }
}

class _ActivitiesTeacherTab extends StatelessWidget {
  final CourseModel course;
  final Color color;

  const _ActivitiesTeacherTab(
      {required this.course, required this.color});

  @override
  Widget build(BuildContext context) {
    if (course.activities.isEmpty) {
      return Center(
        child: Text('Sin actividades.',
            style:
                GoogleFonts.inter(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: course.activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final activity = course.activities[index];
        final daysLeft =
            activity.dueDate.difference(DateTime.now()).inDays;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.assignment_outlined,
                    color: color, size: 20),
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
                    Text(
                      '${activity.type} · ${daysLeft < 0 ? 'Vencida' : 'Vence en $daysLeft días'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
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
  final List<_StudentData> students;

  const _StudentsTab({required this.students});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final s = students[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.courseColor(index),
                child: Text(
                  s.name[0],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Última: ${s.lastActivity}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: s.progress,
                              backgroundColor: AppColors.surface2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                s.progress >= 0.7
                                    ? AppColors.primary
                                    : s.progress >= 0.4
                                        ? AppColors.warning
                                        : AppColors.error,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(s.progress * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!s.isUpToDate) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.all(16),
      children: [
        _StatCard(
          title: 'Promedio del grupo',
          value: '3.8',
          subtitle: 'Sobre 5.0',
          icon: Icons.grade_outlined,
          color: color,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Tasa de entrega',
          value: '84%',
          subtitle: '${(5 * 0.84).round()} de 5 actividades',
          icon: Icons.assignment_turned_in_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
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
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

class _StudentData {
  final String id;
  final String name;
  final double progress;
  final String lastActivity;
  final bool isUpToDate;

  const _StudentData(
      this.id, this.name, this.progress, this.lastActivity, this.isUpToDate);
}
