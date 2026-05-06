import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class _Badge {
  final String emoji;
  final String title;
  final String description;
  final bool unlocked;

  const _Badge({
    required this.emoji,
    required this.title,
    required this.description,
    required this.unlocked,
  });
}

const _badges = [
  _Badge(
      emoji: '🔥',
      title: 'En racha',
      description: '7 días consecutivos',
      unlocked: true),
  _Badge(
      emoji: '🏆',
      title: 'Primero en llegar',
      description: 'Entrega 3 días antes',
      unlocked: true),
  _Badge(
      emoji: '📚',
      title: 'Estudioso',
      description: '10 tareas completadas',
      unlocked: true),
  _Badge(
      emoji: '⚡',
      title: 'Velocista',
      description: 'Completa 5 tareas en un día',
      unlocked: false),
  _Badge(
      emoji: '🌟',
      title: 'Perfeccionista',
      description: '100% a tiempo en una semana',
      unlocked: false),
  _Badge(
      emoji: '👑',
      title: 'Leyenda',
      description: '30 días consecutivos',
      unlocked: false),
  _Badge(
      emoji: '🎯',
      title: 'Enfocado',
      description: 'Sin tareas vencidas por 2 semanas',
      unlocked: false),
  _Badge(
      emoji: '💪',
      title: 'Constante',
      description: '50 tareas completadas',
      unlocked: false),
];

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Logros'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(51)),
            ),
            child: Row(
              children: [
                const Text('🏅', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3 logros desbloqueados',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'de ${_badges.length} disponibles',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'DESBLOQUEADOS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _badges
                .where((b) => b.unlocked)
                .map((b) => _BadgeTile(badge: b))
                .toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'POR DESBLOQUEAR',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _badges
                .where((b) => !b.unlocked)
                .map((b) => _BadgeTile(badge: b))
                .toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final _Badge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: badge.unlocked
              ? AppColors.warning.withAlpha(25)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badge.unlocked
                ? AppColors.warning.withAlpha(76)
                : AppColors.border,
            width: badge.unlocked ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.emoji,
              style: TextStyle(
                fontSize: 28,
                color: badge.unlocked ? null : const Color(0x00000000),
              ),
            ),
            if (!badge.unlocked)
              const Icon(Icons.lock_outline_rounded,
                  size: 28, color: AppColors.textDisabled),
            const SizedBox(height: 6),
            Text(
              badge.title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badge.unlocked
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              badge.title,
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? AppColors.primary.withAlpha(25)
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge.unlocked ? '✓ Desbloqueado' : 'Bloqueado',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: badge.unlocked
                      ? AppColors.primary
                      : AppColors.textDisabled,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
