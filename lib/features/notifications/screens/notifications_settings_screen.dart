import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _taskReminders = true;
  bool _dueDates = true;
  bool _groupActivity = true;
  bool _coursePosts = true;
  bool _aiSuggestions = true;
  bool _doNotDisturb = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s4),
        children: [
          _SectionCard(
            title: 'Tareas',
            icon: '📋',
            children: [
              _NotifRow(
                label: 'Recordatorios de tareas',
                value: _taskReminders,
                onChanged: (v) => setState(() => _taskReminders = v),
              ),
              _NotifRow(
                label: 'Alertas de vencimiento',
                subtitle: '24h y 2h antes del deadline',
                value: _dueDates,
                onChanged: (v) => setState(() => _dueDates = v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          _SectionCard(
            title: 'Grupos',
            icon: '👥',
            children: [
              _NotifRow(
                label: 'Nueva actividad del grupo',
                value: _groupActivity,
                onChanged: (v) => setState(() => _groupActivity = v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          _SectionCard(
            title: 'Cursos',
            icon: '📚',
            children: [
              _NotifRow(
                label: 'Nuevas actividades del docente',
                value: _coursePosts,
                onChanged: (v) => setState(() => _coursePosts = v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          _SectionCard(
            title: 'Captus IA',
            icon: '🤖',
            children: [
              _NotifRow(
                label: 'Sugerencias proactivas',
                subtitle: 'Consejos y planificación automática',
                value: _aiSuggestions,
                onChanged: (v) => setState(() => _aiSuggestions = v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s5),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r5),
              border: Border.all(
                color: _doNotDisturb
                    ? AppColors.error.withAlpha(AppAlpha.a30)
                    : AppColors.border,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔕', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo no molestar',
                            style: tt.titleMedium,
                          ),
                          Text(
                            'Silencia todas las notificaciones',
                            style: tt.labelLarge!.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _doNotDisturb,
                      onChanged: (v) =>
                          setState(() => _doNotDisturb = v),
                    ),
                  ],
                ),
                if (_doNotDisturb) ...[
                  const SizedBox(height: AppSpacing.s3),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    'Horario: 10:00 PM — 8:00 AM',
                    style: tt.bodySmall!.copyWith(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero),
                    child: const Text('Cambiar horario',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r5),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.s2),
              Text(
                title,
                style: tt.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          ...children,
        ],
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifRow({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: tt.titleSmall),
                if (subtitle != null)
                  Text(subtitle!,
                      style: tt.labelMedium!.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
