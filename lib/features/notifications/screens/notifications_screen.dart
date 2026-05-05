import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/app_notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0;
  List<AppNotification> _notifications = AppNotification.mockList;

  List<AppNotification> get _filtered => _selectedTab == 0
      ? _notifications
      : _notifications.where((n) => !n.isRead).toList();

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
        return Colors.purple;
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
            onPressed: () => setState(() {
              _notifications = _notifications
                  .map((n) => AppNotification(
                        id: n.id,
                        type: n.type,
                        title: n.title,
                        body: n.body,
                        isRead: true,
                        createdAt: n.createdAt,
                        deepLink: n.deepLink,
                      ))
                  .toList();
            }),
            child: Text(
              'Todo leído',
              style: GoogleFonts.inter(fontSize: 13),
            ),
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
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = e.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : AppColors.surface2,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.black : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✅', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'Estás al día.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.border, height: 1),
                    itemBuilder: (_, i) {
                      final n = _filtered[i];
                      final color = _colorForType(n.type);
                      return Dismissible(
                        key: ValueKey(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppColors.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: Colors.white),
                        ),
                        onDismissed: (_) => setState(() =>
                            _notifications.removeWhere((x) => x.id == n.id)),
                        child: GestureDetector(
                          onTap: () {
                            if (n.deepLink != null) context.push(n.deepLink!);
                          },
                          child: Container(
                            color: n.isRead
                                ? Colors.transparent
                                : AppColors.primary.withAlpha(8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(_iconForType(n.type),
                                      size: 20, color: color),
                                ),
                                const SizedBox(width: 12),
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
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: n.isRead
                                                    ? FontWeight.normal
                                                    : FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _timeLabel(n.createdAt),
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        n.body,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!n.isRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 4),
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
                  ),
          ),
        ],
      ),
    );
  }
}
