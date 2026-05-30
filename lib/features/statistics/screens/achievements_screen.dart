import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../models/achievement.dart';
import '../providers/achievements_provider.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(achievementsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Logros',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: achievementsAsync.when(
        loading: () => _buildSkeleton(),
        error: (e, _) => _buildError(e.toString()),
        data: (state) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(achievementsProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.s4),
            children: [
              _StatsHeader(state: state),
              const SizedBox(height: AppSpacing.s4),
              _FilterChips(state: state, ref: ref),
              const SizedBox(height: AppSpacing.s5),
              if (state.unlocked.isNotEmpty) ...[
                _sectionLabel('DESBLOQUEADOS (${state.unlocked.length})'),
                const SizedBox(height: AppSpacing.s3),
                _AchievementsGrid(achievements: state.unlocked),
                const SizedBox(height: AppSpacing.s5),
              ],
              if (state.locked.isNotEmpty) ...[
                _sectionLabel('POR DESBLOQUEAR (${state.locked.length})'),
                const SizedBox(height: AppSpacing.s3),
                _AchievementsGrid(achievements: state.locked),
              ],
              if (state.unlocked.isEmpty && state.locked.isEmpty)
                _buildEmpty(),
              const SizedBox(height: AppSpacing.s8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s4),
      children: [
        const LoadingShimmer(height: 110, borderRadius: 16),
        const SizedBox(height: AppSpacing.s4),
        const LoadingShimmer(height: 44, borderRadius: 22),
        const SizedBox(height: AppSpacing.s5),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            9,
            (_) => const LoadingShimmer(height: 110, borderRadius: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.textDisabled),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'No se pudieron cargar los logros',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              message,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.s6),
            TextButton.icon(
              onPressed: () => ref.invalidate(achievementsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'No hay logros en esta categoría',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Header ──────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  final AchievementsState state;
  const _StatsHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final unlocked = state.totalUnlocked;
    final progress = unlocked / kTotalAchievements;
    final last = state.lastUnlocked;
    final stats = state.stats;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.r7),
        border: Border.all(color: AppColors.primary.withAlpha(AppAlpha.a20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 40)),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlocked logro${unlocked == 1 ? '' : 's'} desbloqueado${unlocked == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: AppColors.textPrimary),
                    ),
                    Text(
                      'de $kTotalAchievements disponibles',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (stats != null) ...[
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% completado',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r1),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (last != null && last.unlockedAt != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.s1),
                Expanded(
                  child: Text(
                    'Último: ${last.definition.name} — ${_formatDate(last.unlockedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ── Filter Chips ──────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final AchievementsState state;
  final WidgetRef ref;
  const _FilterChips({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(
            context: context,
            label: 'Todos',
            isActive: state.activeFilter == null,
            color: AppColors.primary,
            onTap: () =>
                ref.read(achievementsProvider.notifier).setFilter(null),
          ),
          const SizedBox(width: AppSpacing.s2),
          ...AchievementDifficulty.values.map((d) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s2),
                child: _chip(
                  context: context,
                  label: d.label,
                  isActive: state.activeFilter == d,
                  color: d.color,
                  onTap: () =>
                      ref.read(achievementsProvider.notifier).setFilter(d),
                ),
              )),
        ],
      ),
    );
  }

  Widget _chip({
    required BuildContext context,
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: tt.titleSmall!.copyWith(color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ── Achievements Grid ─────────────────────────────────────────────────────────

class _AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementsGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: achievements
          .map((a) => _AchievementTile(achievement: a))
          .toList(),
    );
  }
}

// ── Achievement Tile ──────────────────────────────────────────────────────────

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final def = achievement.definition;
    final difficulty = def.difficulty;
    final unlocked = achievement.isCompleted;

    return GestureDetector(
      onTap: () => _showDetailSheet(context, achievement),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: unlocked
              ? difficulty.color.withAlpha(AppAlpha.a12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r5),
          border: Border.all(
            color: unlocked
                ? difficulty.color.withAlpha(AppAlpha.a40)
                : AppColors.border,
            width: unlocked ? 1.5 : 0.5,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: difficulty.color.withAlpha(AppAlpha.a15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unlocked)
              Text(def.icon, style: const TextStyle(fontSize: 28))
            else
              _LockedEmoji(icon: def.icon),
            const SizedBox(height: AppSpacing.s1),
            Text(
              unlocked ? def.name : '???',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: unlocked
                    ? AppColors.textPrimary
                    : AppColors.textDisabled),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!unlocked) ...[
              const SizedBox(height: AppSpacing.s1),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: achievement.progressPercent,
                  minHeight: 4,
                  backgroundColor: difficulty.color.withAlpha(AppAlpha.a15),
                  valueColor: AlwaysStoppedAnimation<Color>(difficulty.color),
                ),
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                '${achievement.progress}/${def.targetValue}',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.textDisabled),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Locked Emoji (blur effect) ────────────────────────────────────────────────

class _LockedEmoji extends StatelessWidget {
  final String icon;
  const _LockedEmoji({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: 36,
                height: 36,
                color: AppColors.surface.withAlpha(180),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lock_rounded,
                  size: 18,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail Bottom Sheet ───────────────────────────────────────────────────────

void _showDetailSheet(BuildContext context, Achievement achievement) {
  final def = achievement.definition;
  final difficulty = def.difficulty;
  final unlocked = achievement.isCompleted;

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.s5),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (unlocked)
            Text(def.icon, style: const TextStyle(fontSize: 56))
          else
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded,
                  size: 36, color: AppColors.textDisabled),
            ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            unlocked ? def.name : '???',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            unlocked ? def.description : 'Desbloquea este logro para ver su descripción',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s4),
          // Dificultad chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: difficulty.color.withAlpha(AppAlpha.a12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: difficulty.color.withAlpha(80)),
            ),
            child: Text(
              difficulty.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          // Barra de progreso
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r1),
                  child: LinearProgressIndicator(
                    value: achievement.progressPercent,
                    minHeight: 10,
                    backgroundColor: difficulty.color.withAlpha(AppAlpha.a15),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(difficulty.color),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Text(
                '${achievement.progress}/${def.targetValue}',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          // Estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.primary.withAlpha(AppAlpha.a10)
                  : AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: unlocked
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.s1),
                      Text(
                        achievement.unlockedAt != null
                            ? 'Desbloqueado el ${_formatDate(achievement.unlockedAt!)}'
                            : 'Desbloqueado',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.primary),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 16, color: AppColors.textDisabled),
                      const SizedBox(width: AppSpacing.s1),
                      Text(
                        'Bloqueado — ¡sigue adelante!',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.textDisabled),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

String _formatDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
