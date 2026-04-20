import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  bool _accessTasks = true;
  bool _accessCalendar = true;
  bool _accessGroups = true;
  bool _voiceResponses = false;
  bool _proactiveSuggestions = true;
  int _toneIndex = 1; // 0=Formal, 1=Amigable, 2=Motivacional

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configuración IA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('PERMISOS DE ACCESO'),
          _ToggleItem(
            icon: '📋',
            label: 'Acceso a mis tareas',
            subtitle: 'La IA puede ver y sugerir sobre tus tareas',
            value: _accessTasks,
            onChanged: (v) => setState(() => _accessTasks = v),
          ),
          _ToggleItem(
            icon: '📅',
            label: 'Acceso a mi calendario',
            subtitle: 'La IA puede leer tus fechas y entregas',
            value: _accessCalendar,
            onChanged: (v) => setState(() => _accessCalendar = v),
          ),
          _ToggleItem(
            icon: '👥',
            label: 'Acceso a mis grupos',
            subtitle: 'La IA puede leer actividades de grupos',
            value: _accessGroups,
            onChanged: (v) => setState(() => _accessGroups = v),
          ),

          const SizedBox(height: 8),
          _SectionLabel('COMPORTAMIENTO'),

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tono de respuestas',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: ['Formal', 'Amigable', 'Motivacional']
                      .asMap()
                      .entries
                      .map((e) {
                    final isSelected = _toneIndex == e.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _toneIndex = e.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.surface2,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              e.value,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          _ToggleItem(
            icon: '🔊',
            label: 'Respuestas por voz',
            subtitle: 'Lee las respuestas en voz alta',
            value: _voiceResponses,
            onChanged: (v) => setState(() => _voiceResponses = v),
          ),
          _ToggleItem(
            icon: '💡',
            label: 'Sugerencias proactivas',
            subtitle: 'Captus IA te sugiere acciones sin que preguntes',
            value: _proactiveSuggestions,
            onChanged: (v) => setState(() => _proactiveSuggestions = v),
          ),

          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('Borrar historial de conversaciones'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
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
