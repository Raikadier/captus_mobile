import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticFeedback = true;
  bool _analytics = true;
  String _language = 'Español';
  String _theme = 'Oscuro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'GENERAL',
            children: [
              _PickerRow(
                icon: Icons.language_rounded,
                label: 'Idioma',
                value: _language,
                onTap: () => _showPicker(
                  context,
                  title: 'Idioma',
                  options: ['Español', 'English'],
                  current: _language,
                  onSelect: (v) => setState(() => _language = v),
                ),
              ),
              const Divider(height: 0, color: AppColors.border, thickness: 0.5),
              _PickerRow(
                icon: Icons.dark_mode_rounded,
                label: 'Tema',
                value: _theme,
                onTap: () => _showPicker(
                  context,
                  title: 'Tema',
                  options: ['Oscuro', 'Claro', 'Sistema'],
                  current: _theme,
                  onSelect: (v) => setState(() => _theme = v),
                ),
              ),
              const Divider(height: 0, color: AppColors.border, thickness: 0.5),
              _ToggleRow(
                icon: Icons.vibration_rounded,
                label: 'Vibración',
                subtitle: 'Retroalimentación háptica',
                value: _hapticFeedback,
                onChanged: (v) => setState(() => _hapticFeedback = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'PRIVACIDAD',
            children: [
              _ToggleRow(
                icon: Icons.analytics_outlined,
                label: 'Datos de uso',
                subtitle: 'Ayuda a mejorar Captus',
                value: _analytics,
                onChanged: (v) => setState(() => _analytics = v),
              ),
              const Divider(height: 0, color: AppColors.border, thickness: 0.5),
              _LinkRow(
                icon: Icons.privacy_tip_outlined,
                label: 'Política de privacidad',
                onTap: () {},
              ),
              const Divider(height: 0, color: AppColors.border, thickness: 0.5),
              _LinkRow(
                icon: Icons.description_outlined,
                label: 'Términos de uso',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'CUENTA',
            children: [
              _LinkRow(
                icon: Icons.notifications_outlined,
                label: 'Notificaciones',
                onTap: () => context.push('/notifications/settings'),
              ),
              const Divider(height: 0, color: AppColors.border, thickness: 0.5),
              _LinkRow(
                icon: Icons.lock_outline_rounded,
                label: 'Seguridad',
                onTap: () => context.push('/settings/security'),
              ),
              const Divider(height: 0, color: AppColors.border, thickness: 0.5),
              _LinkRow(
                icon: Icons.delete_outline_rounded,
                label: 'Eliminar cuenta',
                color: AppColors.error,
                onTap: () => _confirmDelete(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Captus v1.0.0',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textDisabled),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showPicker(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...options.map((opt) => ListTile(
                title: Text(opt, style: GoogleFonts.inter(fontSize: 14)),
                trailing: opt == current
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Eliminar cuenta',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'Esta acción es irreversible. Se eliminarán todos tus datos.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textPrimary)),
            ),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(width: 12),
            Expanded(
              child:
                  Text(label, style: GoogleFonts.inter(fontSize: 13, color: c)),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
