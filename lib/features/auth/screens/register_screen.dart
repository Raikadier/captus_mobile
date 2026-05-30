import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/captus_pressable.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedRole = 0;

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

  static const _taglines = [
    'Tu academia, tu ritmo',
    'Aprende sin límites',
    'Cada tarea cuenta',
    ' building your future',
    'Organiza tu éxito',
    ' focus on learning',
    'Tu tiempo es valioso',
  ];

  String _getRandomTagline() {
    final index = DateTime.now().microsecond % _taglines.length;
    return _taglines[index];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final role = _selectedRole == 0 ? 'student' : 'teacher';
    final error = await ref.read(authProvider.notifier).signUp(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: role,
        );

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      return;
    }

    context.go('/register/success', extra: _emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s2),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(AppAlpha.a30),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🌵',
                              style: TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text('Captus', style: tt.displaySmall),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        _getRandomTagline(),
                        style: tt.bodySmall!
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),

                // Role selector
                Text('Soy...',
                    style: tt.titleMedium),
                const SizedBox(height: AppSpacing.s3),
                Row(
                  children: [
                    _RoleCard(
                      label: 'Estudiante',
                      emoji: '🎓',
                      isSelected: _selectedRole == 0,
                      onTap: () => setState(() => _selectedRole = 0),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    _RoleCard(
                      label: 'Docente',
                      emoji: '📚',
                      isSelected: _selectedRole == 1,
                      onTap: () => setState(() => _selectedRole = 1),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s6),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Ej. Juan Pérez',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 4) {
                      return 'El nombre debe tener al menos 4 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'usuario@ejemplo.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || !_emailRegex.hasMatch(v.trim())) {
                      return 'Ingresa un correo válido (ej. usuario@ejemplo.com)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                    helperText:
                        'Mín. 8 caracteres, mayúscula, minúscula y número',
                  ),
                  validator: (v) {
                    if (v == null || !_passwordRegex.hasMatch(v)) {
                      return 'Mínimo 8 caracteres, una mayúscula, una minúscula y un número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Confirma tu contraseña';
                    }
                    if (v != _passwordCtrl.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.s3),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: AppSpacing.s8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary),
                        )
                      : const Text('Continuar'),
                ),
                const SizedBox(height: AppSpacing.s6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: CaptusPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r5),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: AppSpacing.s2),
              Text(
                label,
                style: tt.headlineSmall!.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3, vertical: AppSpacing.s2 + 2),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(AppAlpha.a10),
        borderRadius: BorderRadius.circular(AppRadius.r3),
        border: Border.all(color: AppColors.error.withAlpha(AppAlpha.a30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 16),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(message,
                style: tt.bodySmall!.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
