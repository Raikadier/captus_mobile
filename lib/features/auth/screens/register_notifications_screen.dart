import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class RegisterNotificationsScreen extends StatefulWidget {
  const RegisterNotificationsScreen({super.key});

  @override
  State<RegisterNotificationsScreen> createState() =>
      _RegisterNotificationsScreenState();
}

class _RegisterNotificationsScreenState
    extends State<RegisterNotificationsScreen> {
  bool _taskReminders = true;
  bool _dueDateAlerts = true;
  bool _groupMessages = true;
  bool _aiSuggestions = true;

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s2),
              const _StepBar(),
              const SizedBox(height: AppSpacing.s8),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(AppAlpha.a10),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🔔',
                            style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s5),
                    Text('Mantente al tanto', style: tt.headlineMedium),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'Las notificaciones inteligentes de Captus te avisan antes de que sea tarde.',
                      style: tt.bodyMedium!.copyWith(
                          color: AppColors.textSecondary, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              _NotifToggle(
                icon: '📋',
                label: 'Recordatorios de tareas',
                subtitle: 'Te avisamos antes de que venzan',
                value: _taskReminders,
                onChanged: (v) => setState(() => _taskReminders = v),
              ),
              _NotifToggle(
                icon: '⏰',
                label: 'Alertas de vencimiento',
                subtitle: '2h y 24h antes del deadline',
                value: _dueDateAlerts,
                onChanged: (v) => setState(() => _dueDateAlerts = v),
              ),
              _NotifToggle(
                icon: '👥',
                label: 'Actividad de grupos',
                subtitle: 'Nuevas tareas y mensajes del equipo',
                value: _groupMessages,
                onChanged: (v) => setState(() => _groupMessages = v),
              ),
              _NotifToggle(
                icon: '🤖',
                label: 'Sugerencias de Captus IA',
                subtitle: 'Consejos proactivos para organizarte',
                value: _aiSuggestions,
                onChanged: (v) =>
                    setState(() => _aiSuggestions = v),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Activar notificaciones'),
              ),
              const SizedBox(height: AppSpacing.s3),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Ahora no'),
              ),
              const SizedBox(height: AppSpacing.s6),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s3),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r5),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.headlineSmall),
                Text(subtitle,
                    style: tt.bodySmall!
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 2 ? AppSpacing.s1 : 0),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
