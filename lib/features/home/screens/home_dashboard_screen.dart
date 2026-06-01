import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../models/task.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/widgets/course_card.dart';
import '../../../shared/widgets/captus_pressable.dart';
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

    final coursesAsync = ref.watch(coursesProvider);
    final courses = coursesAsync.asData?.value ?? <CourseModel>[];
    final streakDays =
        ref.watch(userStatisticsProvider).value?.currentStreak ?? 0;

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

    final upcomingTasks = pendingTasks.where((t) {
      if (t.dueDate == null) return false;
      final diff = t.dueDate!.difference(DateTime.now());
      return diff.inDays < 3 && diff.inDays >= 0;
    }).toList();

    final todayTasks = upcomingTasks.where((t) {
      final diff = t.dueDate!.difference(DateTime.now());
      return diff.inHours < 24;
    }).toList();

    return Scaffold(
      restorationId: 'home_dashboard_screen',
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────────
          _DashboardAppBar(user: user),

          // ── Greeting ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _GreetingHeader(user: user),
          ),

          // ── AI Suggestion hero card ────────────────────────────────────────
          SliverToBoxAdapter(
            child: _AiSuggestionCard(
              taskCount: pendingTasks.length,
              onTap: () => context.push('/ai'),
            ),
          ),

          // ── Stats row ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _StatsRow(
              todayCount: todayTasks.length,
              streakDays: streakDays,
              overdueCount: overdueCount,
            ),
          ),

          // ── Weekly streak ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _WeeklyStreak(),
          ),

          // ── Priority tasks ─────────────────────────────────────────────────
          if (upcomingTasks.isNotEmpty) ...[
            _SectionHeader(
              title: 'Priorizado por IA',
              onSeeAll: () => context.go('/tasks'),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => TaskCard(
                  task: upcomingTasks[i],
                  onTap: () =>
                      context.push('/tasks/${upcomingTasks[i].id}'),
                ),
                childCount: upcomingTasks.length.clamp(0, 3),
              ),
            ),
          ],

          // ── Quick access ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin, AppSpacing.sectionGap,
                AppSpacing.pageMargin, 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.folder_rounded,
                      label: 'Proyectos',
                      color: AppColors.primary,
                      onTap: () => context.push('/projects'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.cardGap),
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.menu_book_rounded,
                      label: 'Modo Estudio',
                      color: AppColors.accentPurple,
                      onTap: () => context.push('/ai/study'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── My courses ─────────────────────────────────────────────────────
          _SectionHeader(
            title: 'Mis materias',
            onSeeAll: () => context.push('/courses'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageMargin,
                ),
                itemCount: courses.length,
                itemBuilder: (_, i) => SizedBox(
                  width: 160,
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.cardGap),
                    child: CourseCard(
                      course: courses[i],
                      onTap: () =>
                          context.push('/courses/${courses[i].id}'),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s25)),
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
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.shadowBase,
      surfaceTintColor: Colors.transparent,
      titleSpacing: AppSpacing.pageMargin,
      title: Row(
        children: [
          // Avatar
          CaptusPressable(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: user.avatarUrl != null &&
                      user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      user.firstName[0].toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.brand700),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.s2),
          // Captus wordmark
          Text(
            'Captus',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: AppColors.primary, letterSpacing: -0.01 * 22),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Buscar',
          onPressed: () => context.push('/search'),
          color: AppColors.textPrimary,
        ),
        // Notification bell with badge dot
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notificaciones',
              color: AppColors.textPrimary,
              onPressed: () => context.push('/notifications'),
            ),
            Positioned(
              right: AppSpacing.s2 + 2,
              top: AppSpacing.s2 + 2,
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
        const SizedBox(width: AppSpacing.s1),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.divider, height: 1),
      ),
    );
  }
}

// ── Greeting ───────────────────────────────────────────────────────────────────

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
    final dateStr =
        DateFormat("EEEE d 'de' MMMM", 'es').format(DateTime.now());
    final dateLabel = dateStr[0].toUpperCase() + dateStr.substring(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin, AppSpacing.sectionGap,
        AppSpacing.pageMargin, AppSpacing.s1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_greeting, ${user.firstName}',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            dateLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── AI Suggestion Hero Card ────────────────────────────────────────────────────
//
// v2: Brand gradient background + brandLg shadow for hero presence.
//

class _AiSuggestionCard extends StatelessWidget {
  final int taskCount;
  final VoidCallback onTap;
  const _AiSuggestionCard({required this.taskCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CaptusPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin, AppSpacing.s4,
          AppSpacing.pageMargin, 0,
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPaddingStd),
        decoration: BoxDecoration(
          gradient: AppGradients.brandHero,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          boxShadow: AppShadows.brandMd,
        ),
        child: Row(
          children: [
            // Cactus icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withAlpha(AppAlpha.a20),
                borderRadius: BorderRadius.circular(AppRadius.r5),
              ),
              child: const Center(
                child: Text('🌵', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CAPTUS SUGIERE',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.textOnPrimary.withAlpha(AppAlpha.a70), letterSpacing: 1.0),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    taskCount > 0
                        ? 'Tienes $taskCount entregas esta semana. Empieza con la más urgente.'
                        : '¡Al día! No tienes tareas pendientes esta semana.',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.textOnPrimary, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s1 + 2),
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withAlpha(AppAlpha.a20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin, AppSpacing.s4,
        AppSpacing.pageMargin, 0,
      ),
      child: Row(
        children: [
          _StatCard(
            value: '$todayCount',
            label: 'Hoy',
            icon: Icons.today_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.cardGap),
          _StatCard(
            value: '$streakDays',
            label: 'Racha',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.streakText,
          ),
          const SizedBox(width: AppSpacing.cardGap),
          _StatCard(
            value: '$overdueCount',
            label: 'Vencidas',
            icon: overdueCount > 0
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: overdueCount > 0 ? AppColors.error : AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s3 + 2, // 14px
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r6),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.xs,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: AppSpacing.s1),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: color, height: 1.2),
            ),
            const SizedBox(height: AppSpacing.s1),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weekly streak tracker ──────────────────────────────────────────────────────

class _WeeklyStreak extends ConsumerWidget {
  const _WeeklyStreak();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final todayIndex = now.weekday - 1;

    final statsAsync = ref.watch(userStatisticsProvider);
    final weeklyData =
        statsAsync.value?.weeklyDailyCompletions ?? List.filled(7, 0);
    final streak = statsAsync.value?.currentStreak ?? 0;

    final activeDays = weeklyData.where((c) => c > 0).length;
    final label = activeDays == 0
        ? 'Completa tareas para iniciar tu racha'
        : activeDays == 1
            ? '1 día productivo esta semana'
            : '$activeDays días productivos esta semana'
                '${streak > 0 ? ' · Racha: $streak 🔥' : ''}';

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin, AppSpacing.cardGap,
        AppSpacing.pageMargin, 0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPaddingStd,
        vertical: AppSpacing.s3 + 2, // 14px
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r6),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) => _DayDot(
              label: days[i],
              isActive: weeklyData[i] > 0,
              isToday: i == todayIndex,
            )),
          ),
          const SizedBox(height: AppSpacing.s2 + 2), // 10px
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isToday ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.s1),
        AnimatedContainer(
          duration: AppDurations.standard,
          curve: AppCurves.springShort,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Active: amber fill — completed task day
            // Today + not active: solid primary fill so TODAY is unmissable
            // Inactive past/future: surface2 with border for definition
            color: isActive
                ? AppColors.streak
                : isToday
                    ? AppColors.primary.withAlpha(AppAlpha.a20)
                    : AppColors.surface2,
            border: Border.all(
              color: isActive
                  ? AppColors.streak
                  : isToday
                      ? AppColors.primary
                      : AppColors.border,
              width: isToday ? 2 : 1,
            ),
          ),
          child: isActive
              ? Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isToday ? AppColors.streakText : AppColors.streakText,
                  ),
                )
              : isToday
                  ? Center(
                      child: Text(
                        '•',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          height: 1,
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
    final tt = Theme.of(context).textTheme;
    return CaptusPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s3,
          horizontal: AppSpacing.s3,
        ),
        decoration: BoxDecoration(
          // Neutral surface — same for both cards (consistency)
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r6),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.xs,
        ),
        child: Row(
          children: [
            // Icon container — feature color ONLY here
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(AppAlpha.a12),
                borderRadius: BorderRadius.circular(AppRadius.r3),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.s2 + 2),
            Expanded(
              child: Text(
                label,
                style: tt.titleSmall,  // neutral text, not color-tinted
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
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
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin, AppSpacing.sectionGap,
          AppSpacing.s2, AppSpacing.s2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s2,
                    vertical: AppSpacing.s1,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Ver todo',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
