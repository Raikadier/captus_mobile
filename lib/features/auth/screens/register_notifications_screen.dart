import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _StepBar(),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🔔', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Mantente al tanto',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Las notificaciones inteligentes de Captus te avisan antes de que sea tarde.',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                onChanged: (v) => setState(() => _aiSuggestions = v),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Activar notificaciones'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Ahora no'),
              ),
              const SizedBox(height: 24),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
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
