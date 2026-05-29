import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Ingresa un correo válido');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final error =
        await ref.read(authProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    } else {
      setState(() {
        _isLoading = false;
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: _sent
              ? _ConfirmationView(email: _emailCtrl.text)
              : _FormView(
                  emailCtrl: _emailCtrl,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  onSend: _send,
                ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final VoidCallback onSend;
  final bool isLoading;
  final String? errorMessage;

  const _FormView({
    required this.emailCtrl,
    required this.onSend,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.s6),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('🔑', style: TextStyle(fontSize: 40))),
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text('¿Olvidaste tu contraseña?',
            style: tt.headlineMedium),
        const SizedBox(height: AppSpacing.s2),
        Text(
          'Ingresa tu correo y te enviaremos instrucciones para restablecerla.',
          style: tt.bodyMedium!
              .copyWith(color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo institucional',
            hintText: 'usuario@institución.edu',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.s3),
          _ErrorBanner(message: errorMessage!),
        ],
        const SizedBox(height: AppSpacing.s6),
        ElevatedButton(
          onPressed: isLoading ? null : onSend,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.textOnPrimary),
                )
              : const Text('Enviar instrucciones'),
        ),
      ],
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  final String email;
  const _ConfirmationView({required this.email});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('✉️', style: TextStyle(fontSize: 64)),
        const SizedBox(height: AppSpacing.s6),
        Text('Revisa tu correo',
            style: tt.headlineMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.s3),
        Text(
          'Enviamos instrucciones a\n$email',
          style: tt.bodyMedium!
              .copyWith(color: AppColors.textSecondary, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s10),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Volver al inicio de sesión'),
        ),
      ],
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
        color: AppColors.error.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withAlpha(76)),
      ),
      child: Text(message,
          style: tt.bodySmall!.copyWith(color: AppColors.error)),
    );
  }
}
