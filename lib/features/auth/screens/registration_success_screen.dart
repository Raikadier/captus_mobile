import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';

class RegistrationSuccessScreen extends ConsumerStatefulWidget {
  final String email;
  const RegistrationSuccessScreen({super.key, required this.email});

  @override
  ConsumerState<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState
    extends ConsumerState<RegistrationSuccessScreen> {
  bool _isResending = false;
  bool _resendSuccess = false;
  String? _errorMessage;

  Future<void> _resendConfirmation() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _resendSuccess = false;
    });

    final error = await ref
        .read(authProvider.notifier)
        .resendConfirmation(widget.email);

    if (!mounted) return;

    setState(() {
      _isResending = false;
      if (error != null) {
        _errorMessage = error;
      } else {
        _resendSuccess = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registro exitoso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s6),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.s12),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.success.withAlpha(76),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                '¡Revisa tu correo!',
                style: tt.headlineLarge!.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Hemos enviado un enlace de confirmación a:',
                style: tt.bodyLarge!
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s2),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4,
                    vertical: AppSpacing.s2 + 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.email,
                  style: tt.titleMedium!
                      .copyWith(color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                'Haz clic en el enlace del correo para activar tu cuenta. '
                'Si no lo encuentras, revisa tu carpeta de spam.',
                style: tt.bodyMedium!.copyWith(
                    color: AppColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s8),
              if (_resendSuccess) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s3,
                      vertical: AppSpacing.s2 + 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.success.withAlpha(76)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: AppSpacing.s2),
                      Text(
                        'Correo reenviado',
                        style: tt.labelLarge!
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
              ],
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s3,
                      vertical: AppSpacing.s2 + 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withAlpha(76)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: AppSpacing.s2),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: tt.bodySmall!
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
              ],
              OutlinedButton.icon(
                onPressed: _isResending ? null : _resendConfirmation,
                icon: _isResending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                    _isResending ? 'Enviando...' : 'Reenviar correo'),
              ),
              const SizedBox(height: AppSpacing.s4),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Ir al inicio de sesión'),
              ),
              const SizedBox(height: AppSpacing.s6),
            ],
          ),
        ),
      ),
    );
  }
}
