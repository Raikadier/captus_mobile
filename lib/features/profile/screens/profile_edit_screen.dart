import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../models/user.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _universityCtrl;
  late final TextEditingController _careerCtrl;
  int _semester = 1;
  bool _initialized = false;
  bool _saving = false;
  Uint8List? _avatarBytes;
  String? _avatarFileName;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _universityCtrl = TextEditingController();
    _careerCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _universityCtrl.dispose();
    _careerCtrl.dispose();
    super.dispose();
  }

  void _loadUser(UserModel user) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = user.name;
    _emailCtrl.text = user.email;
    _universityCtrl.text = user.university ?? '';
    _careerCtrl.text = user.career ?? '';
    _semester = user.semester ?? 1;
    _avatarUrl = user.avatarUrl;
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _avatarBytes = bytes;
      _avatarFileName = image.name.isEmpty ? 'avatar.jpg' : image.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      var avatarUrl = _avatarUrl;
      if (_avatarBytes != null) {
        avatarUrl = await ref.read(userProfileProvider.notifier).uploadAvatar(
              fileName: _avatarFileName ?? 'avatar.jpg',
              bytes: _avatarBytes!,
            );
      }

      await ref.read(userProfileProvider.notifier).updateProfile({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'university': _universityCtrl.text.trim(),
        'career': _careerCtrl.text.trim(),
        'semester': _semester,
        'avatarUrl': avatarUrl ?? '',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado', style: GoogleFonts.inter()),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el perfil: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _saving ? null : () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Guardar',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _EditError(
          message: 'No se pudo cargar el perfil',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (user) {
          _loadUser(user);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        _AvatarPreview(
                          name: _nameCtrl.text,
                          avatarBytes: _avatarBytes,
                          avatarUrl: _avatarUrl,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _saving ? null : _pickAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2,
                                ),
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
                  _SectionLabel(text: 'INFORMACION PERSONAL'),
                  const SizedBox(height: 8),
                  _FieldCard(children: [
                    _FormField(
                      controller: _nameCtrl,
                      label: 'Nombre completo',
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                    ),
                    const Divider(
                        height: 0, color: AppColors.border, thickness: 0.5),
                    _FormField(
                      controller: _emailCtrl,
                      label: 'Correo institucional',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || !v.contains('@') ? 'Email invalido' : null,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _SectionLabel(text: 'INFORMACION ACADEMICA'),
                  const SizedBox(height: 8),
                  _FieldCard(children: [
                    _FormField(
                      controller: _universityCtrl,
                      label: 'Universidad',
                      icon: Icons.school_rounded,
                    ),
                    const Divider(
                        height: 0, color: AppColors.border, thickness: 0.5),
                    _FormField(
                      controller: _careerCtrl,
                      label: 'Carrera',
                      icon: Icons.laptop_rounded,
                    ),
                    const Divider(
                        height: 0, color: AppColors.border, thickness: 0.5),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.layers_rounded,
                              size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Text('Semestre',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          const Spacer(),
                          DropdownButton<int>(
                            value: _semester,
                            dropdownColor: AppColors.surface2,
                            underline: const SizedBox(),
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.textPrimary),
                            items: List.generate(
                              12,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('${i + 1}'),
                              ),
                            ),
                            onChanged: _saving
                                ? null
                                : (v) =>
                                    setState(() => _semester = v ?? _semester),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final String name;
  final Uint8List? avatarBytes;
  final String? avatarUrl;

  const _AvatarPreview({
    required this.name,
    required this.avatarBytes,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = avatarUrl?.trim() ?? '';
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    ImageProvider? image;
    if (avatarBytes != null) {
      image = MemoryImage(avatarBytes!);
    } else if (trimmedUrl.isNotEmpty) {
      image = NetworkImage(trimmedUrl);
    }

    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.primaryDark,
      backgroundImage: image,
      child: image == null
          ? Text(
              initial,
              style: GoogleFonts.inter(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}

class _EditError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EditError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: GoogleFonts.inter(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
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

class _FieldCard extends StatelessWidget {
  final List<Widget> children;
  const _FieldCard({required this.children});

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

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style:
                  GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
