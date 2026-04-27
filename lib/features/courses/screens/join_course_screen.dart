import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';

// ── Provider de inscripción ───────────────────────────────────────────────────
final joinCourseProvider = FutureProvider.autoDispose
    .family<_JoinResult, String>((ref, inviteCode) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  final normalizedCode = inviteCode.trim().toUpperCase();

  if (user == null) {
    return _JoinResult.notLoggedIn;
  }

  if (normalizedCode.isEmpty) {
    return _JoinResult.notFound;
  }

  // 1. Buscar el curso por invite_code
  final courseRes = await supabase
      .from('courses')
      .select('id, title')
      .eq('invite_code', normalizedCode)
      .maybeSingle();

  if (courseRes == null) {
    return _JoinResult.notFound;
  }

  final courseId = courseRes['id'] as int;
  final courseTitle = courseRes['title'] as String;

  // 2. Verificar si ya está inscrito
  final existing = await supabase
      .from('course_enrollments')
      .select('id')
      .eq('course_id', courseId)
      .eq('student_id', user.id)
      .maybeSingle();

  if (existing != null) {
    return _JoinResult.alreadyEnrolled(courseTitle);
  }

  // 3. Inscribir al estudiante
  await supabase.from('course_enrollments').insert({
    'course_id': courseId,
    'student_id': user.id,
  });

  return _JoinResult.success(courseTitle);
});

// ── Resultado de la inscripción ───────────────────────────────────────────────
class _JoinResult {
  final _JoinStatus status;
  final String? courseTitle;

  const _JoinResult._(this.status, [this.courseTitle]);

  static const notLoggedIn = _JoinResult._(_JoinStatus.notLoggedIn);
  static const notFound = _JoinResult._(_JoinStatus.notFound);
  static _JoinResult alreadyEnrolled(String title) =>
      _JoinResult._(_JoinStatus.alreadyEnrolled, title);
  static _JoinResult success(String title) =>
      _JoinResult._(_JoinStatus.success, title);
}

enum _JoinStatus { notLoggedIn, notFound, alreadyEnrolled, success }

// ── Pantalla ──────────────────────────────────────────────────────────────────
class JoinCourseScreen extends ConsumerWidget {
  final String inviteCode;

  const JoinCourseScreen({super.key, required this.inviteCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinAsync = ref.watch(joinCourseProvider(inviteCode));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: joinAsync.when(
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Procesando invitación...'),
                ],
              ),
            ),
            error: (e, _) => _ResultView(
              icon: Icons.error_outline,
              iconColor: Colors.red,
              title: 'Algo salió mal',
              subtitle: 'No pudimos procesar la invitación.\nIntenta de nuevo.',
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

                case _JoinStatus.alreadyEnrolled:
                  return _ResultView(
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                    title: '¡Ya estás inscrito!',
                    subtitle:
                        'Ya eres estudiante de "${result.courseTitle}".',
                    buttonLabel: 'Ver mis cursos',
                    onButton: () => context.go('/courses'),
                  );

                case _JoinStatus.success:
                  return _ResultView(
                    icon: Icons.school_outlined,
                    iconColor: AppColors.primary,
                    title: '¡Te uniste al curso!',
                    subtitle:
                        'Ahora eres estudiante de\n"${result.courseTitle}".',
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

// ── Vista de resultado ────────────────────────────────────────────────────────
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 44, color: iconColor),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onButton,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSuccess ? AppColors.primary : AppColors.textPrimary,
              foregroundColor: isSuccess ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonLabel,
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
