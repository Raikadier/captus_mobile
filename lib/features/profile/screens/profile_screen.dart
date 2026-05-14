import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../statistics/providers/user_statistics_provider.dart';
import '../../statistics/providers/achievements_provider.dart';
import '../../statistics/utils/streak_messages.dart';
import '../../../models/achievement.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
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
                      child: GestureDetector(
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
                              size: 14, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role == 'teacher' ? 'Docente' : 'Estudiante',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildStreakSection(ref),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Academic info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INFORMACIÓN ACADÉMICA',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
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

                const SizedBox(height: 24),

                // Stats con datos reales
                Text(
                  'MIS ESTADÍSTICAS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRealStats(ref),

                const SizedBox(height: 24),

                // Quick links
                Text(
                  'ACCESO RÁPIDO',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
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
                            data: (s) => '${s.totalUnlocked}/$kTotalAchievements',
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

                const SizedBox(height: 24),

                // Settings
                Text(
                  'CUENTA',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de racha compacta que aparece debajo del avatar.
  Widget _buildStreakSection(WidgetRef ref) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasStreak
                  ? [
                      AppColors.warning.withAlpha(30),
                      AppColors.warning.withAlpha(10),
                    ]
                  : [AppColors.surface2, AppColors.surface2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasStreak
                  ? AppColors.warning.withAlpha(100)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          hasStreak ? '$streak días' : 'Sin racha',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: hasStreak
                                ? AppColors.warning
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: hasStreak
                                ? AppColors.warning.withAlpha(25)
                                : AppColors.surface3,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: hasStreak
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: GoogleFonts.inter(
                        fontSize: 11,
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
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: AppColors.warning, size: 16),
                    Text(
                      '${stats.bestStreak}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    Text(
                      'mejor',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
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
  Widget _buildRealStats(WidgetRef ref) {
    final statsAsync = ref.watch(userStatisticsProvider);

    return statsAsync.when(
      loading: () => Row(
        children: [
          _StatTile(
              icon: Icons.check_circle_rounded,
              label: 'Completadas',
              value: '…',
              color: AppColors.primary),
          const SizedBox(width: 8),
          _StatTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Racha',
              value: '…',
              color: AppColors.warning),
          const SizedBox(width: 8),
          _StatTile(
              icon: Icons.percent_rounded,
              label: 'Éxito',
              value: '…',
              color: const Color(0xFFAB47BC)),
        ],
      ),
      error: (_, __) => Row(
        children: [
          _StatTile(
              icon: Icons.check_circle_rounded,
              label: 'Completadas',
              value: '-',
              color: AppColors.primary),
          const SizedBox(width: 8),
          _StatTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Racha',
              value: '-',
              color: AppColors.warning),
          const SizedBox(width: 8),
          _StatTile(
              icon: Icons.percent_rounded,
              label: 'Éxito',
              value: '-',
              color: const Color(0xFFAB47BC)),
        ],
      ),
      data: (stats) => Row(
        children: [
          _StatTile(
              icon: Icons.check_circle_rounded,
              label: 'Completadas',
              value: '${stats.completedTasks}',
              color: AppColors.primary),
          const SizedBox(width: 8),
          _StatTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Racha',
              value: '${stats.currentStreak}d',
              color: AppColors.warning),
          const SizedBox(width: 8),
          _StatTile(
              icon: Icons.percent_rounded,
              label: 'Éxito',
              value:
                  '${(stats.completionPercentage * 100).toInt()}%',
              color: const Color(0xFFAB47BC)),
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
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('¿Seguro que quieres salir?',
            style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: Text('Salir', style: TextStyle(color: AppColors.error)),
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
        borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textPrimary)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: c),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.inter(fontSize: 13, color: c)),
                ),
                if (trailingLabel != null && trailingLabel!.isNotEmpty) ...[
                  Text(
                    trailingLabel!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

Widget _buildAvatarInitial(String initial) {
  return Center(
    child: Text(
      initial,
      style: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  );
}
