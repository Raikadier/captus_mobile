import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

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
        padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _doNotDisturb
                    ? AppColors.error.withAlpha(76)
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo no molestar',
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Silencia todas las notificaciones',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary),
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
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  Text(
                    'Horario: 10:00 PM — 8:00 AM',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(fontSize: 13)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
