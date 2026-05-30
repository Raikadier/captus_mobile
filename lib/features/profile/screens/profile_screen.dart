import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/auth_provider.dart';
import '../../statistics/providers/user_statistics_provider.dart';
import '../../statistics/providers/achievements_provider.dart';
import '../../statistics/utils/streak_messages.dart';
import '../../../models/achievement.dart';
import '../../../shared/widgets/captus_pressable.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Scaffold(
      restorationId: 'profile_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.s6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryDark,
                      ),
                      child: ClipOval(
                        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? Image.network(
                                user.avatarUrl!,
                                fit: BoxFit.cover,
                                semanticLabel: 'Foto de perfil',
                                width: 88,
                                height: 88,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarInitial(initial),
                              )
                            : _buildAvatarInitial(initial),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CaptusPressable(
                        onTap: () => context.push('/profile/edit'),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.surface, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 14, color: AppColors.textOnPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.s3),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  _roleDisplayText(user.role),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSpacing.s4),
                // Streak section is only meaningful for students and teachers.
                if (user.role == 'student' || user.role == 'teacher')
                  _buildStreakSection(context, ref),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.s4),

          // Academic info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INFORMACIÓN ACADÉMICA',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: AppSpacing.s2),
                _InfoCard(children: [
                  if (user.institutionName != null)
                    _InfoRow(
                      icon: Icons.business_rounded,
                      label: 'Institución',
                      value: user.institutionName!,
                    )
                  else
                    _InfoRow(
                      icon: Icons.school_rounded,
                      label: 'Universidad',
                      value: user.university ?? 'No especificada',
                    ),
                  _InfoRow(
                    icon: Icons.laptop_rounded,
                    label: 'Carrera',
                    value: user.career ?? 'No especificada',
                  ),
                  _InfoRow(
                    icon: Icons.layers_rounded,
                    label: 'Semestre',
                    value: user.semester != null
                        ? '${user.semester}° semestre'
                        : 'No especificado',
                  ),
                  _InfoRow(
                    icon: Icons.edit_note_rounded,
                    label: 'Biografía',
                    value: user.bio?.isNotEmpty == true
                        ? user.bio!
                        : 'No especificada',
                    isLast: true,
                  ),
                ]),

                // Stats and quick-access links are only relevant for
                // students and teachers. Admins go straight to CUENTA.
                if (user.role == 'student' || user.role == 'teacher') ...[
                  SizedBox(height: AppSpacing.s6),

                  Text(
                    'MIS ESTADÍSTICAS',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s2),
                  _buildRealStats(context, ref),

                  SizedBox(height: AppSpacing.s6),

                  Text(
                    'ACCESO RÁPIDO',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s2),
                  _InfoCard(children: [
                    _LinkRow(
                      icon: Icons.bar_chart_rounded,
                      label: 'Mis estadísticas',
                      onTap: () => context.push('/statistics'),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final label = ref
                            .watch(achievementsProvider)
                            .maybeWhen(
                              data: (s) =>
                                  '${s.totalUnlocked}/$kTotalAchievements',
                              orElse: () => '',
                            );
                        return _LinkRow(
                          icon: Icons.emoji_events_rounded,
                          label: 'Mis logros',
                          trailingLabel: label,
                          onTap: () =>
                              context.push('/statistics/achievements'),
                        );
                      },
                    ),
                    _LinkRow(
                      icon: Icons.notifications_outlined,
                      label: 'Notificaciones',
                      onTap: () => context.push('/notifications/settings'),
                      isLast: true,
                    ),
                  ]),
                ],

                SizedBox(height: AppSpacing.s6),

                // Settings
                Text(
                  'CUENTA',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: AppSpacing.s2),
                _InfoCard(children: [
                  _LinkRow(
                    icon: Icons.settings_outlined,
                    label: 'Configuración',
                    onTap: () => context.push('/settings'),
                  ),
                  _LinkRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Seguridad',
                    onTap: () => context.push('/settings/security'),
                  ),
                  _LinkRow(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    color: AppColors.error,
                    onTap: () => _confirmLogout(context, ref),
                    isLast: true,
                  ),
                ]),

                SizedBox(height: AppSpacing.s8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de racha compacta que aparece debajo del avatar.
  Widget _buildStreakSection(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatisticsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final streak = stats.currentStreak;
        final emoji = getStreakEmoji(streak);
        final title = getStreakTitle(streak);
        final message = getStreakMessage(streak);
        final hasStreak = streak > 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasStreak
                  ? [
                      AppColors.warning.withAlpha(AppAlpha.a12),
                      AppColors.warning.withAlpha(AppAlpha.a04),
                    ]
                  : [AppColors.surface2, AppColors.surface2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.r6),
            border: Border.all(
              color: hasStreak
                  ? AppColors.warning.withAlpha(AppAlpha.a40)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          hasStreak ? '$streak días' : 'Sin racha',
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            color: hasStreak
                                ? AppColors.warning
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s1),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: hasStreak
                                ? AppColors.warning.withAlpha(AppAlpha.a10)
                                : AppColors.surface3,
                            borderRadius: BorderRadius.circular(AppRadius.r2),
                          ),
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: hasStreak
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (stats.bestStreak > 0) ...[
                SizedBox(width: AppSpacing.s2),
                Column(
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: AppColors.warning, size: 16),
                    Text(
                      '${stats.bestStreak}',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    Text(
                      'mejor',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Tiles de estadísticas con datos reales del proveedor.
  Widget _buildRealStats(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatisticsProvider);

    return statsAsync.when(
      loading: () => Row(
        children: [
          _StatTile(
              icon: Icons.check_circle_rounded,
              label: 'Completadas',
              value: '…',
              color: AppColors.primary),
          SizedBox(width: AppSpacing.s2),
          _StatTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Racha',
              value: '…',
              color: AppColors.warning),
          SizedBox(width: AppSpacing.s2),
          _StatTile(
              icon: Icons.percent_rounded,
              label: 'Éxito',
              value: '…',
              color: AppColors.accentPurple),
        ],
      ),
      error: (_, __) => Row(
        children: [
          _StatTile(
              icon: Icons.check_circle_rounded,
              label: 'Completadas',
              value: '-',
              color: AppColors.primary),
          SizedBox(width: AppSpacing.s2),
          _StatTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Racha',
              value: '-',
              color: AppColors.warning),
          SizedBox(width: AppSpacing.s2),
          _StatTile(
              icon: Icons.percent_rounded,
              label: 'Éxito',
              value: '-',
              color: AppColors.accentPurple),
        ],
      ),
      data: (stats) => Row(
        children: [
          _StatTile(
              icon: Icons.check_circle_rounded,
              label: 'Completadas',
              value: '${stats.completedTasks}',
              color: AppColors.primary),
          SizedBox(width: AppSpacing.s2),
          _StatTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Racha',
              value: '${stats.currentStreak}d',
              color: AppColors.warning),
          SizedBox(width: AppSpacing.s2),
          _StatTile(
              icon: Icons.percent_rounded,
              label: 'Éxito',
              value:
                  '${(stats.completionPercentage * 100).toInt()}%',
              color: AppColors.accentPurple),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Cerrar sesión',
            style: Theme.of(context).textTheme.headlineMedium),
        content: Text('¿Seguro que quieres salir?',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: Text('Salir', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r5),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.s3),
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              Text(value,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 0, color: AppColors.border, thickness: 0.5),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  final Color? color;
  final String? trailingLabel;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
    this.color,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
            child: Row(
              children: [
                Icon(icon, size: 18, color: c),
                SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: c)),
                ),
                if (trailingLabel != null && trailingLabel!.isNotEmpty) ...[
                  Text(
                    trailingLabel!,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s1),
                ],
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 0, color: AppColors.border, thickness: 0.5),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r5),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: AppSpacing.s1),
            Text(value,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: AppColors.textPrimary)),
            Text(label,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

String _roleDisplayText(String role) {
  switch (role) {
    case 'teacher':
      return 'Docente';
    case 'admin':
      return 'Administrador';
    case 'superadmin':
      return 'Super Admin';
    default:
      return 'Estudiante';
  }
}

Widget _buildAvatarInitial(String initial) {
  return Center(
    child: Text(
      initial,
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  );
}
