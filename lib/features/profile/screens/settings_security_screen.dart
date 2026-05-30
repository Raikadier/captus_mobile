import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class SettingsSecurityScreen extends StatefulWidget {
  const SettingsSecurityScreen({super.key});

  @override
  State<SettingsSecurityScreen> createState() => _SettingsSecurityScreenState();
}

class _SettingsSecurityScreenState extends State<SettingsSecurityScreen> {
  bool _biometrics = false;
  bool _twoFactor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seguridad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s4),
        children: [
          // Security score
          Container(
            padding: const EdgeInsets.all(AppSpacing.s5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(AppAlpha.a12),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.r7),
              border: Border.all(
                  color: AppColors.primary.withAlpha(AppAlpha.a20), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(AppAlpha.a10),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withAlpha(AppAlpha.a30)),
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: AppColors.primary, size: 26),
                ),
                SizedBox(width: AppSpacing.s4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguridad básica',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppColors.textPrimary),
                    ),
                    Text(
                      'Activa 2FA para mayor protección',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.s5),

          _SectionLabel(text: 'ACCESO'),
          SizedBox(height: AppSpacing.s2),
          _SettingsCard(children: [
            _ToggleRow(
              icon: Icons.fingerprint_rounded,
              label: 'Biometría',
              subtitle: 'Huella dactilar / Face ID',
              value: _biometrics,
              onChanged: (v) => setState(() => _biometrics = v),
            ),
            const Divider(height: 0, color: AppColors.border, thickness: 0.5),
            _ToggleRow(
              icon: Icons.verified_user_rounded,
              label: 'Verificación en 2 pasos',
              subtitle: 'Código por correo al iniciar sesión',
              value: _twoFactor,
              onChanged: (v) => setState(() => _twoFactor = v),
            ),
          ]),

          SizedBox(height: AppSpacing.s5),

          _SectionLabel(text: 'CONTRASEÑA'),
          SizedBox(height: AppSpacing.s2),
          _SettingsCard(children: [
            _ActionRow(
              icon: Icons.lock_reset_rounded,
              label: 'Cambiar contraseña',
              onTap: () => _showChangePasswordSheet(context),
            ),
            const Divider(height: 0, color: AppColors.border, thickness: 0.5),
            _ActionRow(
              icon: Icons.help_outline_rounded,
              label: 'Recuperar contraseña',
              onTap: () => context.push('/forgot-password'),
            ),
          ]),

          SizedBox(height: AppSpacing.s5),

          _SectionLabel(text: 'SESIONES'),
          SizedBox(height: AppSpacing.s2),
          _SettingsCard(children: [
            _SessionRow(
              device: 'Dispositivo actual',
              location: 'Valledupar, Colombia',
              isCurrent: true,
            ),
            const Divider(height: 0, color: AppColors.border, thickness: 0.5),
            _SessionRow(
              device: 'Web — Chrome',
              location: 'Hace 3 días',
              isCurrent: false,
              onRevoke: () {},
            ),
          ]),

          SizedBox(height: AppSpacing.s8),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r8)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.s6,
          right: AppSpacing.s6,
          top: AppSpacing.s6,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cambiar contraseña',
                style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: AppSpacing.s5),
            _PasswordField(controller: currentCtrl, label: 'Contraseña actual'),
            SizedBox(height: AppSpacing.s3),
            _PasswordField(controller: newCtrl, label: 'Nueva contraseña'),
            SizedBox(height: AppSpacing.s3),
            _PasswordField(
                controller: confirmCtrl, label: 'Confirmar contraseña'),
            SizedBox(height: AppSpacing.s5),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Actualizar',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.textOnPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r5),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: children),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s1),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final String device;
  final String location;
  final bool isCurrent;
  final VoidCallback? onRevoke;

  const _SessionRow({
    required this.device,
    required this.location,
    required this.isCurrent,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
      child: Row(
        children: [
          Icon(
            isCurrent ? Icons.smartphone_rounded : Icons.computer_rounded,
            size: 18,
            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
          ),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textPrimary)),
                Text(location,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(AppAlpha.a10),
                borderRadius: BorderRadius.circular(AppRadius.r2),
              ),
              child: Text('Actual',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600))
            )
          else
            TextButton(
              onPressed: onRevoke,
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text('Revocar',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: AppColors.error)),
            ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const _PasswordField({required this.controller, required this.label});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
