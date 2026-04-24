import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../core/providers/statistics_provider.dart';
import '../../../models/user.dart';
import '../../../shared/widgets/streak_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
<<<<<<< Updated upstream
    final profileAsync = ref.watch(userProfileProvider);
    final user = profileAsync.asData?.value ?? UserModel.fromLocalUser(ref.watch(currentUserProvider));
    final statsAsync = ref.watch(statisticsProvider);
=======
    final localUser = ref.watch(currentUserProvider);
    final user = localUser != null
        ? UserModel(
            id: localUser.id,
            name: localUser.name,
            email: localUser.email,
            university: localUser.university,
            career: localUser.career,
            semester: localUser.semester,
            role: localUser.role == 'teacher' ? UserRole.teacher : UserRole.student,
            avatarUrl: localUser.avatarUrl,
            bio: localUser.bio,
          )
        : UserModel.mock;
>>>>>>> Stashed changes

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryDark,
                      child: Text(
                        user.firstName[0],
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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
                const SizedBox(height: 16),
                StreakBadge(days: statsAsync.asData?.value.currentStreak ?? 0, size: StreakSize.mini),
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
                  _InfoRow(
                    icon: Icons.school_rounded,
                    label: 'Universidad',
                    value: user.university ?? '',
                  ),
                  _InfoRow(
                    icon: Icons.laptop_rounded,
                    label: 'Carrera',
                    value: user.career ?? '',
                  ),
                  _InfoRow(
                    icon: Icons.layers_rounded,
                    label: 'Semestre',
                    value: '${user.semester}° semestre',
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: 24),

                // Stats
                Text(
                  'ESTADÍSTICAS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatTile(
                        icon: Icons.check_circle_rounded,
                        label: 'Completadas',
                        value: '${statsAsync.asData?.value.completedTasks ?? 0}',
                        color: AppColors.primary),
                    const SizedBox(width: 8),
                    _StatTile(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Racha',
                        value: '${statsAsync.asData?.value.currentStreak ?? 0}d',
                        color: AppColors.warning),
                    const SizedBox(width: 8),
                    _StatTile(
                        icon: Icons.school_rounded,
                        label: 'Materias',
                        value: '${statsAsync.asData?.value.activeCourses ?? 0}',
                        color: const Color(0xFFAB47BC)),
                  ],
                ),

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
                    label: 'Mi progreso',
                    onTap: () => context.push('/statistics'),
                  ),
                  _LinkRow(
                    icon: Icons.emoji_events_rounded,
                    label: 'Mis logros',
                    onTap: () => context.push('/statistics/achievements'),
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
              // Router redirect handles navigation to /login automatically.
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

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
    this.color,
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
