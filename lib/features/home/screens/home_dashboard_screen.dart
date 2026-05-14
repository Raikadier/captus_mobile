import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/widgets/course_card.dart';
import '../../statistics/providers/user_statistics_provider.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localUser = ref.watch(currentUserProvider);
    final user = localUser != null
        ? UserModel(
            id: localUser.id,
            name: localUser.name,
            email: localUser.email,
            university: localUser.university,
            career: localUser.career,
            semester: localUser.semester,
            role: localUser.role == 'teacher'
                ? UserRole.teacher
                : UserRole.student,
            avatarUrl: localUser.avatarUrl,
            bio: localUser.bio,
          )
        : UserModel.mock;

    final courses = CourseModel.mockList;
    final streakDays = ref.watch(userStatisticsProvider).value?.currentStreak ?? 0;

    final pendingTasksAsync = ref.watch(pendingTasksProvider);
    final overdueTasksAsync = ref.watch(overdueTasksProvider);

    final pendingTasks = pendingTasksAsync.when(
      data: (tasks) => tasks,
      loading: () => <TaskModel>[],
      error: (_, __) => <TaskModel>[],
    );

    final overdueCount = overdueTasksAsync.when(
      data: (tasks) => tasks.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final todayTasks = pendingTasks.where((t) {
      if (t.dueDate == null) return false;
      final diff = t.dueDate!.difference(DateTime.now());
      return diff.inHours < 24 && t.dueDate!.isAfter(DateTime.now());
    }).toList();

    final upcomingTasks = pendingTasks.where((t) {
      if (t.dueDate == null) return false;
      final diff = t.dueDate!.difference(DateTime.now());
      return diff.inDays < 3 && diff.inDays >= 0;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────────
          _DashboardAppBar(user: user),

          // ── Saludo + fecha ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _GreetingHeader(user: user),
          ),

          // ── Tarjeta sugerencia IA ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _AiSuggestionCard(
              taskCount: pendingTasks.length,
              onTap: () => context.push('/ai'),
            ),
          ),

          // ── Stats row ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _StatsRow(
              todayCount: todayTasks.length,
              streakDays: streakDays,
              overdueCount: overdueCount,
            ),
          ),

          // ── Racha semanal ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _WeeklyStreak(),
          ),

          // ── Tareas prioritarias ─────────────────────────────────────────────
          if (upcomingTasks.isNotEmpty) ...[
            _SectionHeader(
              title: 'Priorizado por IA',
              onSeeAll: () => context.go('/tasks'),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => TaskCard(
                  task: upcomingTasks[i],
                  onTap: () => context.push('/tasks/${upcomingTasks[i].id}'),
                ),
                childCount: upcomingTasks.length.clamp(0, 3),
              ),
            ),
          ],

          // ── Accesos rápidos ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.folder_rounded,
                      label: 'Proyectos',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => context.push('/projects'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.menu_book_rounded,
                      label: 'Modo Estudio',
                      color: AppColors.primary,
                      onTap: () => context.push('/ai/study'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Mis materias ────────────────────────────────────────────────────
          _SectionHeader(
            title: 'Mis materias',
            onSeeAll: () => context.push('/courses'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: courses.length,
                itemBuilder: (_, i) => SizedBox(
                  width: 152,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CourseCard(
                      course: courses[i],
                      onTap: () => context.push('/courses/${courses[i].id}'),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── AppBar ─────────────────────────────────────────────────────────────────────

class _DashboardAppBar extends StatelessWidget {
  final UserModel user;
  const _DashboardAppBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              backgroundImage:
                  user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      user.firstName[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Captus',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        // Notificaciones
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () => context.push('/notifications'),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.border, height: 1),
      ),
    );
  }
}

// ── Saludo ─────────────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final UserModel user;
  const _GreetingHeader({required this.user});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat("EEEE d 'de' MMMM", 'es').format(DateTime.now());
    // Capitaliza primera letra
    final dateLabel = dateStr[0].toUpperCase() + dateStr.substring(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, ${user.firstName}',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13,
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

// ── Tarjeta sugerencia IA ──────────────────────────────────────────────────────

class _AiSuggestionCard extends StatelessWidget {
  final int taskCount;
  final VoidCallback onTap;
  const _AiSuggestionCard({required this.taskCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icono cactus / IA
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🌵', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CAPTUS SUGIERE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withAlpha(180),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tienes $taskCount entregas esta semana. Empieza por Estructuras de Datos — vence mañana.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int todayCount;
  final int streakDays;
  final int overdueCount;

  const _StatsRow({
    required this.todayCount,
    required this.streakDays,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _StatCard(
            value: '$todayCount',
            label: 'Tareas hoy',
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: '$streakDays 🔥',
            label: 'Días racha',
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: '$overdueCount',
            label: 'Por entregar',
            color: overdueCount > 0 ? AppColors.error : AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Racha semanal ──────────────────────────────────────────────────────────────

class _WeeklyStreak extends ConsumerWidget {
  const _WeeklyStreak();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    // weekday: Mon=1 … Sun=7 → índice 0-6
    final todayIndex = now.weekday - 1;

    final statsAsync = ref.watch(userStatisticsProvider);
    // weeklyDailyCompletions[i] = tareas completadas ese día (0 = sin completar)
    final weeklyData = statsAsync.value?.weeklyDailyCompletions ??
        List.filled(7, 0);
    final streak = statsAsync.value?.currentStreak ?? 0;

    final activeDays = weeklyData.where((c) => c > 0).length;
    final label = activeDays == 0
        ? 'Completa tareas para iniciar tu racha'
        : activeDays == 1
            ? '1 día productivo esta semana'
            : '$activeDays días productivos esta semana'
              '${streak > 0 ? ' · Racha: $streak 🔥' : ''}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return _DayDot(
                label: days[i],
                isActive: weeklyData[i] > 0,
                isToday: i == todayIndex,
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isToday;

  const _DayDot({
    required this.label,
    required this.isActive,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.streak : AppColors.surface2,
            border:
                isToday ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          child: isActive
              ? Center(
                  child: Text(
                    '✓',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.streakText,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

// ── Quick access card ──────────────────────────────────────────────────────────

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 8, 10),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Ver todo',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
