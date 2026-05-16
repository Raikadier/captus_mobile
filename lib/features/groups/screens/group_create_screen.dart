import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _isPrivate = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // TODO: wire to real API when groups backend is ready
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Grupo "${_nameCtrl.text.trim()}" creado.',
          style: GoogleFonts.inter(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface2,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Nuevo grupo',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Crear',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Avatar placeholder ─────────────────────────────────────
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(AppAlpha.a15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.group_rounded,
                        color: AppColors.primary, size: 40),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.textOnPrimary, size: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Nombre ────────────────────────────────────────────────
            _SectionLabel('INFORMACIÓN DEL GRUPO'),
            _buildField(
              controller: _nameCtrl,
              label: 'Nombre del grupo',
              hint: 'Ej. Proyecto Final — Ing. Software',
              icon: Icons.group_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (v.trim().length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Descripción ───────────────────────────────────────────
            _buildField(
              controller: _descriptionCtrl,
              label: 'Descripción (opcional)',
              hint: 'De qué trata este grupo…',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // ── Privacidad ────────────────────────────────────────────
            _SectionLabel('PRIVACIDAD'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (_isPrivate
                              ? AppColors.warning
                              : AppColors.success)
                          .withAlpha(AppAlpha.a15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isPrivate
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      color:
                          _isPrivate ? AppColors.warning : AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPrivate ? 'Privado' : 'Público',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _isPrivate
                              ? 'Solo por invitación'
                              : 'Cualquiera puede unirse con código',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPrivate,
                    onChanged: (v) => setState(() => _isPrivate = v),
                    activeColor: AppColors.warning,
                    inactiveTrackColor:
                        AppColors.success.withAlpha(AppAlpha.a30),
                    inactiveThumbColor: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 13, color: AppColors.textDisabled),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
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
      padding: const EdgeInsets.only(bottom: 10, top: 4),
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
