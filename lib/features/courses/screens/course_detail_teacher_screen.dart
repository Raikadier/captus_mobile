import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/courses_provider.dart';

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

  int get _courseId => int.tryParse(widget.courseId) ?? 0;

  void _showShareQRModal(BuildContext context, TeacherCourse course) {
    final color = AppColors.courseColor(course.colorIndex);
    final joinLink = 'captus://join?code=${course.inviteCode}';

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _QRFullScreen(
          course: course,
          color: color,
          joinLink: joinLink,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, TeacherCourse course) {
    final color = AppColors.courseColor(course.colorIndex);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          course.title[0].toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${course.inviteCode} · ${course.studentCount} estudiantes',
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
              ),
              const Divider(height: 1, thickness: 0.5),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickAction(
                      icon: Icons.edit_outlined,
                      label: 'Editar',
                      onTap: () => Navigator.pop(context),
                    ),
                    _QuickAction(
                      icon: Icons.copy_outlined,
                      label: 'Duplicar',
                      onTap: () => Navigator.pop(context),
                    ),
                    _QuickAction(
                      icon: Icons.share_outlined,
                      label: 'Compartir',
                      onTap: () {
                        Navigator.pop(context);
                        _showShareQRModal(context, course);
                      },
                    ),
                    _QuickAction(
                      icon: Icons.archive_outlined,
                      label: 'Archivar',
                      color: AppColors.warning,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline,
                            color: Colors.red, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Eliminar curso',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(teacherCourseDetailProvider(_courseId));

    return courseAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text('Error al cargar el curso',
              style: GoogleFonts.inter(color: AppColors.textSecondary)),
        ),
      ),
      data: (course) {
        if (course == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text('Curso no encontrado',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
          );
        }
        final color = AppColors.courseColor(course.colorIndex);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: 160,
                backgroundColor: color,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_2, color: Colors.white),
                    onPressed: () => _showShareQRModal(context, course),
                    tooltip: 'Compartir QR',
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showMenu(context, course),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  // FIX Bug 1: eliminado title: y titlePadding: del
                  // FlexibleSpaceBar. El título solo vive en el background,
                  // así no se duplica cuando el SliverAppBar está expandido.
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 80, 16, 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          course.title,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${course.inviteCode} · ${course.studentCount} estudiantes',
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
                      unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
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
                _ActivitiesTab(courseId: _courseId, color: color),
                _StudentsTab(courseId: _courseId),
                _StatsTab(color: color),
              ],
            ),
          ),
          floatingActionButton: AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index != 0) return const SizedBox.shrink();
              return FloatingActionButton(
                onPressed: () => context
                    .push('/teacher/courses/${course.id}/activity/create'),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.black),
              );
            },
          ),
        );
      },
    );
  }
}

// ── QR Full Screen ────────────────────────────────────────────────────────────
class _QRFullScreen extends StatelessWidget {
  final TeacherCourse course;
  final Color color;
  final String joinLink;

  const _QRFullScreen({
    required this.course,
    required this.color,
    required this.joinLink,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Compartir curso',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.qr_code_2, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Los estudiantes escanean este QR\npara unirse a "${course.title}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            QrImageView(
                              data: joinLink,
                              version: QrVersions.auto,
                              size: 240,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: color, // FIX Bug 2: usa el color del curso
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: color, // FIX Bug 2: usa el color del curso
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: Center(
                                child: Text(
                                  course.title[0].toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Código: ${course.inviteCode}',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Share.share(
                    'Únete a "${course.title}" en Captus:\n$joinLink\n\nCódigo: ${course.inviteCode}',
                    subject: 'Invitación al curso ${course.title}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color, // FIX Bug 2: color del curso
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.share_outlined, size: 20),
                  label: Text(
                    'Compartir enlace',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: course.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Código copiado: ${course.inviteCode}',
                          style: GoogleFonts.inter(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: AppColors.textPrimary,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.copy_outlined, size: 20),
                  label: Text(
                    'Copiar código',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab Actividades ───────────────────────────────────────────────────────────
class _ActivitiesTab extends ConsumerWidget {
  final int courseId;
  final Color color;
  const _ActivitiesTab({required this.courseId, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Sin actividades aún',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca + para crear la primera actividad',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Tab Estudiantes ───────────────────────────────────────────────────────────
class _StudentsTab extends ConsumerWidget {
  final int courseId;
  const _StudentsTab({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(courseStudentsProvider(courseId));

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error al cargar estudiantes',
            style: GoogleFonts.inter(color: AppColors.textSecondary)),
      ),
      data: (students) => students.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'Sin estudiantes aún',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comparte el QR para que se inscriban',
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.separated(
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
                        backgroundColor: AppColors.courseColor(index % 10),
                        backgroundImage: s.avatarUrl != null
                            ? NetworkImage(s.avatarUrl!)
                            : null,
                        child: s.avatarUrl == null
                            ? Text(
                                s.name.isNotEmpty
                                    ? s.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              )
                            : null,
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
                            Text(
                              s.email,
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
              },
            ),
    );
  }
}

// ── Tab Estadísticas ──────────────────────────────────────────────────────────
class _StatsTab extends StatelessWidget {
  final Color color;
  const _StatsTab({required this.color});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatCard(
          title: 'Promedio del grupo',
          value: '--',
          subtitle: 'Próximamente',
          icon: Icons.grade_outlined,
          color: color,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Tasa de entrega',
          value: '--',
          subtitle: 'Próximamente',
          icon: Icons.assignment_turned_in_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Estudiantes en riesgo',
          value: '--',
          subtitle: 'Próximamente',
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
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Acción rápida del menú ────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}