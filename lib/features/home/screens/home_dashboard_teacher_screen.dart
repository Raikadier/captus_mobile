import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/courses_provider.dart';

class HomeDashboardTeacherScreen extends ConsumerWidget {
  const HomeDashboardTeacherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final coursesAsync = ref.watch(teacherCoursesProvider);

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';
    final dateStr = DateFormat("EEEE d 'de' MMMM", 'es').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withAlpha(38),
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'D',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Captus',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withAlpha(76)),
                  ),
                  child: Text(
                    'Docente',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textPrimary,
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),

          // ── Saludo ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, ${user?.name ?? 'Docente'}',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Métricas ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: coursesAsync.when(
              loading: () => const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
              data: (courses) {
                final totalStudents =
                    courses.fold<int>(0, (sum, c) => sum + c.studentCount);
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MetricCard(
                        value: '${courses.length}',
                        label: 'Cursos',
                        icon: Icons.menu_book_outlined,
                      ),
                      _Divider(),
                      _MetricCard(
                        value: '$totalStudents',
                        label: 'Estudiantes',
                        icon: Icons.group_outlined,
                      ),
                      _Divider(),
                      _MetricCard(
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

          // ── Mis Cursos ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
              child: Row(
                children: [
                  Text(
                    'MIS CURSOS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/teacher/courses'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Ver todo',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: coursesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error al cargar cursos',
                    style: GoogleFonts.inter(color: AppColors.textSecondary)),
              ),
              data: (courses) => courses.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.school_outlined,
                                size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'Aún no tienes cursos',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu primer curso para comenzar',
                              style: GoogleFonts.inter(
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/teacher/courses'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                              ),
                              icon: const Icon(Icons.add),
                              label: Text(
                                'Crear curso',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: courses
                          .take(3)
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => _CourseRow(
                                course: e.value,
                                onTap: () => context
                                    .push('/teacher/courses/${e.value.id}'),
                              ))
                          .toList(),
                    ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.black),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

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
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style:
              GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 40,
      color: AppColors.border,
    );
  }
}

class _CourseRow extends StatelessWidget {
  final TeacherCourse course;
  final VoidCallback onTap;

  const _CourseRow({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.courseColor(course.colorIndex);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  Text(
                    '${course.studentCount} estudiantes • ${course.inviteCode}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
