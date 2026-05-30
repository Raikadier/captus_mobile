import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/notifications_provider.dart';
import '../../../models/app_notification.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../shared/widgets/captus_pressable.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _selectedTab = 0;

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return Icons.check_box_outlined;
      case NotificationType.group:
        return Icons.group_outlined;
      case NotificationType.ai:
        return Icons.auto_awesome_outlined;
      case NotificationType.course:
        return Icons.school_outlined;
      case NotificationType.system:
        return Icons.settings_outlined;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return AppColors.primary;
      case NotificationType.group:
        return AppColors.info;
      case NotificationType.ai:
        return AppColors.warning;
      case NotificationType.course:
        return AppColors.accentPurple;
      case NotificationType.system:
        return AppColors.textSecondary;
    }
  }

  String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    return DateFormat('d MMM', 'es').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final asyncNotifs = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllRead(),
            child: Text('Todo leído', style: tt.titleSmall),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: ['Todas', 'Sin leer'].asMap().entries.map((e) {
                final isSelected = _selectedTab == e.key;
                return CaptusPressable(
                  onTap: () => setState(() => _selectedTab = e.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.s2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surface2,
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                    ),
                    child: Text(
                      e.value,
                      style: tt.titleSmall!.copyWith(color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Expanded(
            child: asyncNotifs.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.s3),
                    Text('No se pudieron cargar las notificaciones',
                        style: tt.bodyMedium!.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.s2),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(notificationsProvider),
                      child: Text('Reintentar', style: tt.titleMedium),
                    ),
                  ],
                ),
              ),
              data: (all) {
                final notifs = _selectedTab == 0
                    ? all
                    : all.where((n) => !n.isRead).toList();

                if (notifs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✅', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: AppSpacing.s3),
                        Text(
                          'Estás al día.',
                          style: tt.headlineSmall!.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
                  itemCount: notifs.length,
                  separatorBuilder: (_, __) => const Divider(
                      color: AppColors.border, height: 1),
                  itemBuilder: (_, i) {
                    final n = notifs[i];
                    final color = _colorForType(n.type);
                    return Dismissible(
                      key: ValueKey(n.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: AppColors.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.s4),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.textOnPrimary),
                      ),
                      onDismissed: (_) =>
                          ref.read(notificationsProvider.notifier).remove(n.id),
                      child: CaptusPressable(
                        onTap: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .markRead(n.id);
                          if (n.deepLink != null) context.push(n.deepLink!);
                        },
                        child: Container(
                          color: n.isRead
                              ? Colors.transparent
                              : AppColors.primary.withAlpha(AppAlpha.a04),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withAlpha(AppAlpha.a10),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_iconForType(n.type),
                                    size: 20, color: color),
                              ),
                              const SizedBox(width: AppSpacing.s3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            style: tt.bodySmall!.copyWith(color: AppColors.textPrimary),
                                          ),
                                        ),
                                        Text(
                                          _timeLabel(n.createdAt),
                                          style: tt.labelMedium!.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.s1),
                                    Text(
                                      n.body,
                                      style: tt.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (!n.isRead) ...[
                                const SizedBox(width: AppSpacing.s2),
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: AppSpacing.s1),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
