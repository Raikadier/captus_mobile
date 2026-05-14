import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/avatar_service.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _universityCtrl;
  late final TextEditingController _careerCtrl;
  late final TextEditingController _bioCtrl;
  late int _semester;
  bool _saving = false;
  String? _error;
  XFile? _selectedAvatar;
  Uint8List? _selectedAvatarBytes;
  String? _currentAvatarUrl;
  bool _uploadingAvatar = false;
  String? _institutionId;
  String? _institutionName;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl       = TextEditingController(text: user?.name ?? '');
    _universityCtrl = TextEditingController(text: user?.university ?? '');
    _careerCtrl     = TextEditingController(text: user?.career ?? '');
    _bioCtrl        = TextEditingController(text: user?.bio ?? '');
    _semester       = user?.semester ?? 1;
    _currentAvatarUrl = user?.avatarUrl;
    _institutionId = user?.institutionId;
    _institutionName = user?.institutionName;
  }

  Future<void> _pickAvatar(ImageSource source) async {
    debugPrint('[_pickAvatar] START - source: $source');
    setState(() { _uploadingAvatar = true; });
    
    try {
      final file = await AvatarService.instance.pickAvatar(source: source);
      debugPrint('[_pickAvatar] Result file: $file');
      
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedAvatar = file;
          _selectedAvatarBytes = bytes;
        });
        debugPrint('[_pickAvatar] State updated - _selectedAvatar set');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imagen seleccionada: ${file.path.split('/').last}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        debugPrint('[_pickAvatar] File was NULL - ImagePicker returned null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ No se detectó ninguna imagen. Intenta de nuevo.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e, stack) {
      debugPrint('[_pickAvatar] ERROR: $e');
      debugPrint('[_pickAvatar] Stack: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() { _uploadingAvatar = false; });
      debugPrint('[_pickAvatar] END - _uploadingAvatar: false');
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: Text('Tomar foto', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: Text('Elegir de galería', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: AppColors.error),
                  title: Text('Eliminar foto', style: GoogleFonts.inter(color: AppColors.error)),
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() {
                      _selectedAvatar = null;
                      _currentAvatarUrl = '';
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _universityCtrl.dispose();
    _careerCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });

    try {
      String? newAvatarUrl;
      
      if (_selectedAvatar != null) {
        newAvatarUrl = await AvatarService.instance.uploadAvatar(_selectedAvatar!);
        if (newAvatarUrl != null) {
          await AvatarService.instance.updateUserAvatarUrl(newAvatarUrl);
        }
      } else if (_currentAvatarUrl == '') {
        await AvatarService.instance.deleteAvatar();
      }

      final updates = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'university': _universityCtrl.text.trim(),
        'career': _careerCtrl.text.trim(), // El key del mapa se envía como 'career' y se convierte a 'carrer' en el provider
        'semester': _semester,
        'bio': _bioCtrl.text.trim(),
      };
      
      if (newAvatarUrl != null) {
        updates['avatarUrl'] = newAvatarUrl;
      } else if (_currentAvatarUrl == '') {
        updates['avatarUrl'] = '';
      }

      await ref.read(authProvider.notifier).updateProfile(updates);

      if (mounted) context.go('/');
    } catch (e) {
      debugPrint('[ProfileEditScreen] Error saving: $e');
      setState(() {
        _saving = false;
        _error = 'Error al guardar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Guardar',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withAlpha(60)),
                  ),
                  child: Text(_error!,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.error)),
                ),

              // Avatar
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImageSourcePicker,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryDark,
                        ),
                        child: ClipOval(
                          child: _uploadingAvatar
                              ? const Center(child: CircularProgressIndicator())
                              : _selectedAvatarBytes != null
                                  ? Image.memory(
                                      _selectedAvatarBytes!,
                                      fit: BoxFit.cover,
                                      width: 96,
                                      height: 96,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildAvatarInitial();
                                      },
                                    )
                                  : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty)
                                      ? Image.network(
                                          _currentAvatarUrl!,
                                          fit: BoxFit.cover,
                                          width: 96,
                                          height: 96,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (_, error, __) {
                                            debugPrint('[Image.network] Error: $error');
                                            return _buildAvatarInitial();
                                          },
                                        )
                                      : _buildAvatarInitial(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourcePicker,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _SectionLabel(text: 'INFORMACIÓN PERSONAL'),
              const SizedBox(height: 8),
              _FieldCard(children: [
                _FormField(
                  controller: _nameCtrl,
                  label: 'Nombre completo',
                  icon: Icons.person_outline_rounded,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'El nombre es requerido' : null,
                ),
              ]),

              const SizedBox(height: 20),

              _SectionLabel(text: 'INFORMACIÓN ACADÉMICA'),
              const SizedBox(height: 8),
              _FieldCard(children: [
                if (_institutionId != null && _institutionName != null) ...[
                  _ReadOnlyField(
                    label: 'Institución',
                    value: _institutionName!,
                    icon: Icons.business_rounded,
                  ),
                  const Divider(height: 0, color: AppColors.border, thickness: 0.5),
                ] else ...[
                  _FormField(
                    controller: _universityCtrl,
                    label: 'Universidad',
                    icon: Icons.school_rounded,
                  ),
                  const Divider(height: 0, color: AppColors.border, thickness: 0.5),
                ],
                _FormField(
                  controller: _careerCtrl,
                  label: 'Carrera',
                  icon: Icons.laptop_rounded,
                ),
                const Divider(height: 0, color: AppColors.border, thickness: 0.5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.layers_rounded,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text('Semestre',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textSecondary)),
                      const Spacer(),
                      DropdownButton<int>(
                        value: _semester,
                        dropdownColor: AppColors.surface2,
                        underline: const SizedBox(),
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textPrimary),
                        items: List.generate(10, (i) => DropdownMenuItem(
                            value: i + 1, child: Text('${i + 1}°'))),
                        onChanged: (v) => setState(() => _semester = v ?? _semester),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0, color: AppColors.border, thickness: 0.5),
                _FormField(
                  controller: _bioCtrl,
                  label: 'Biografía',
                  icon: Icons.edit_note_rounded,
                  maxLines: 3,
                ),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarInitial() {
    final name = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'U';
    final initial = name[0].toUpperCase();
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: 38,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary, letterSpacing: 0.8,
        ),
      );
}

class _FieldCard extends StatelessWidget {
  final List<Widget> children;
  const _FieldCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(children: children),
      );
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 12 : 4),
        child: Row(
          crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 2 : 0),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                validator: validator,
                maxLines: maxLines,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
