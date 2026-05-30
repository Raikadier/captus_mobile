import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/ai_chat_provider.dart';
import '../../../core/providers/ai_settings_provider.dart';
import '../../../core/providers/conversations_provider.dart';
import '../../../shared/widgets/captus_pressable.dart';

class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(aiSettingsProvider);

    return Scaffold(
      restorationId: 'ai_settings_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Configuración IA',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
      ),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error al cargar configuración',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        data: (settings) => _SettingsBody(settings: settings),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  final AiSettings settings;
  const _SettingsBody({required this.settings});

  void _update(WidgetRef ref, AiSettings updated) =>
      ref.read(aiSettingsProvider.notifier).save(updated);

  Future<void> _clearHistory(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Borrar historial',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        content: Text(
          'Se eliminarán todas las conversaciones del servidor. Esta acción no se puede deshacer.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      // Delete all conversations server-side AND clear local state.
      await ref.read(conversationsProvider.notifier).deleteAll();
      ref.read(aiChatProvider.notifier).clear();
      if (!context.mounted) return;
      context.pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo borrar el historial.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.s4),
      children: [
        _SectionLabel('PERMISOS DE ACCESO'),
        _ToggleItem(
          icon: '📋',
          label: 'Acceso a mis tareas',
          subtitle: 'La IA puede ver y sugerir sobre tus tareas',
          value: settings.accessTasks,
          onChanged: (v) =>
              _update(ref, settings.copyWith(accessTasks: v)),
        ),
        _ToggleItem(
          icon: '📅',
          label: 'Acceso a mi calendario',
          subtitle: 'La IA puede leer tus fechas y entregas',
          value: settings.accessCalendar,
          onChanged: (v) =>
              _update(ref, settings.copyWith(accessCalendar: v)),
        ),
        _ToggleItem(
          icon: '👥',
          label: 'Acceso a mis grupos',
          subtitle: 'La IA puede leer actividades de grupos',
          value: settings.accessGroups,
          onChanged: (v) =>
              _update(ref, settings.copyWith(accessGroups: v)),
        ),

        SizedBox(height: AppSpacing.s2),
        _SectionLabel('COMPORTAMIENTO'),

        // ── Tone selector ──────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s3),
          padding: EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r5),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tono de respuestas',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s1),
              Text('Cómo responde Captus IA',
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: AppSpacing.s3),
              Row(
                children: ['Formal', 'Amigable', 'Motivacional']
                    .asMap()
                    .entries
                    .map((e) {
                  final isSelected = settings.toneIndex == e.key;
                  return Expanded(
                    child: CaptusPressable(
                      onTap: () =>
                          _update(ref, settings.copyWith(toneIndex: e.key)),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        margin: EdgeInsets.only(
                            right: e.key < 2 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.surface2,
                          borderRadius: BorderRadius.circular(AppRadius.r3),
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
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
          value: settings.voiceResponses,
          onChanged: (v) =>
              _update(ref, settings.copyWith(voiceResponses: v)),
        ),
        _ToggleItem(
          icon: '💡',
          label: 'Sugerencias proactivas',
          subtitle: 'Captus IA te sugiere acciones sin que preguntes',
          value: settings.proactiveSuggestions,
          onChanged: (v) =>
              _update(ref, settings.copyWith(proactiveSuggestions: v)),
        ),

        SizedBox(height: AppSpacing.s6),

        // ── Borrar historial ───────────────────────────────────────────
        _SectionLabel('DATOS'),
        OutlinedButton.icon(
          onPressed: () => _clearHistory(context, ref),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error, width: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r5)),
          ),
          icon: const Icon(Icons.delete_sweep_outlined, size: 18),
          label: Text(
            'Borrar historial de conversaciones',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(height: AppSpacing.s2),
        Text(
          'Elimina permanentemente todas tus conversaciones del servidor.',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: AppSpacing.s8),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3, top: AppSpacing.s2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
        borderRadius: BorderRadius.circular(AppRadius.r5),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
