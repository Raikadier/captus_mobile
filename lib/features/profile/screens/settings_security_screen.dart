import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

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
        padding: const EdgeInsets.all(16),
        children: [
          // Security score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(30),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primary.withAlpha(51), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.primary.withAlpha(76)),
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguridad básica',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Activa 2FA para mayor protección',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _SectionLabel(text: 'ACCESO'),
          const SizedBox(height: 8),
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

          const SizedBox(height: 20),

          _SectionLabel(text: 'CONTRASEÑA'),
          const SizedBox(height: 8),
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

          const SizedBox(height: 20),

          _SectionLabel(text: 'SESIONES'),
          const SizedBox(height: 8),
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

          const SizedBox(height: 32),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cambiar contraseña',
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _PasswordField(
                controller: currentCtrl, label: 'Contraseña actual'),
            const SizedBox(height: 12),
            _PasswordField(
                controller: newCtrl, label: 'Nueva contraseña'),
            const SizedBox(height: 12),
            _PasswordField(
                controller: confirmCtrl, label: 'Confirmar contraseña'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Actualizar',
                    style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
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
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isCurrent ? Icons.smartphone_rounded : Icons.computer_rounded,
            size: 18,
            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textPrimary)),
                Text(location,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Actual',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            )
          else
            TextButton(
              onPressed: onRevoke,
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text('Revocar',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.error)),
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
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
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
