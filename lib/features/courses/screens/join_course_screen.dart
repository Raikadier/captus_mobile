import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/api_client.dart';
import '../../../core/providers/courses_provider.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final joinCourseProvider =
    FutureProvider.autoDispose.family<_JoinResult, String>((ref, inviteCode) async {
  final normalizedCode = inviteCode.trim().toUpperCase();
  if (normalizedCode.isEmpty) return _JoinResult.notFound;

  try {
    final res = await ApiClient.instance.post<dynamic>(
      '/enrollments/join-by-code',
      data: {'code': normalizedCode},
    );
    final data = res.data;
    final title = data is Map
        ? (data['courses']?['title'] ?? data['title'] ?? normalizedCode).toString()
        : normalizedCode;
    return _JoinResult.success(title);
  } on DioException catch (e) {
    final serverMsg = (() {
      final d = e.response?.data;
      return (d is Map ? d['error'] ?? d['message'] : null) as String?;
    })();

    if (e.response?.statusCode == 401) return _JoinResult.notLoggedIn;

    // Backend throws "Ya estás inscrito en este curso" for duplicates
    if (serverMsg != null &&
        (serverMsg.contains('inscrito') || serverMsg.contains('enrolled'))) {
      return _JoinResult.alreadyEnrolled(normalizedCode);
    }
    if (serverMsg != null &&
        (serverMsg.contains('inválido') || serverMsg.contains('invalid'))) {
      return _JoinResult.notFound;
    }

    return _JoinResult.error(serverMsg ?? 'Error desconocido');
  }
});

// ─── Result model ────────────────────────────────────────────────────────────

class _JoinResult {
  final _JoinStatus status;
  final String? message;

  const _JoinResult._(this.status, [this.message]);

  static const notLoggedIn = _JoinResult._(_JoinStatus.notLoggedIn);
  static const notFound = _JoinResult._(_JoinStatus.notFound);
  static _JoinResult error(String message) =>
      _JoinResult._(_JoinStatus.error, message);
  static _JoinResult alreadyEnrolled(String title) =>
      _JoinResult._(_JoinStatus.alreadyEnrolled, title);
  static _JoinResult success(String title) =>
      _JoinResult._(_JoinStatus.success, title);
}

enum _JoinStatus { notLoggedIn, notFound, error, alreadyEnrolled, success }

// ─── Screen ──────────────────────────────────────────────────────────────────

class JoinCourseScreen extends ConsumerWidget {
  final String inviteCode;

  const JoinCourseScreen({super.key, required this.inviteCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final joinAsync = ref.watch(joinCourseProvider(inviteCode));

    // Refresh courses list when successfully joined
    ref.listen(joinCourseProvider(inviteCode), (_, next) {
      if (next.asData?.value.status == _JoinStatus.success) {
        ref.invalidate(coursesProvider);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
          child: joinAsync.when(
            loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.s5),
                  Text('Procesando invitación...', style: tt.bodyMedium),
                ],
              ),
            ),
            error: (e, _) => _ResultView(
              icon: Icons.error_outline,
              iconColor: AppColors.error,
              title: 'Algo salió mal',
              subtitle: 'No pudimos procesar la invitación.\n$e',
              buttonLabel: 'Volver al inicio',
              onButton: () => context.go('/home'),
            ),
            data: (result) {
              switch (result.status) {
                case _JoinStatus.notLoggedIn:
                  return _ResultView(
                    icon: Icons.lock_outline,
                    iconColor: AppColors.primary,
                    title: 'Inicia sesión primero',
                    subtitle:
                        'Debes tener una cuenta en Captus para unirte a un curso.',
                    buttonLabel: 'Ir a iniciar sesión',
                    onButton: () => context.go('/login'),
                  );
                case _JoinStatus.notFound:
                  return _ResultView(
                    icon: Icons.search_off_outlined,
                    iconColor: AppColors.warning,
                    title: 'Código inválido',
                    subtitle:
                        'No encontramos ningún curso con el código "$inviteCode".',
                    buttonLabel: 'Volver al inicio',
                    onButton: () => context.go('/home'),
                  );
                case _JoinStatus.error:
                  return _ResultView(
                    icon: Icons.error_outline,
                    iconColor: AppColors.error,
                    title: 'Algo salió mal',
                    subtitle: result.message ??
                        'No pudimos procesar la invitación.\nIntenta de nuevo.',
                    buttonLabel: 'Volver al inicio',
                    onButton: () => context.go('/home'),
                  );
                case _JoinStatus.alreadyEnrolled:
                  return _ResultView(
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.success,
                    title: 'Ya estás inscrito',
                    subtitle: 'Ya eres estudiante de "${result.message}".',
                    buttonLabel: 'Ver mis cursos',
                    onButton: () => context.go('/courses'),
                  );
                case _JoinStatus.success:
                  return _ResultView(
                    icon: Icons.school_outlined,
                    iconColor: AppColors.primary,
                    title: 'Te uniste al curso',
                    subtitle:
                        'Ahora eres estudiante de\n"${result.message}".',
                    buttonLabel: 'Ver mis cursos',
                    onButton: () => context.go('/courses'),
                    isSuccess: true,
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

// ─── Result view ─────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onButton;
  final bool isSuccess;

  const _ResultView({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onButton,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(AppAlpha.a10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 44, color: iconColor),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: tt.displaySmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.s2 + 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: tt.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onButton,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSuccess ? AppColors.primary : AppColors.textPrimary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r6),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonLabel,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
