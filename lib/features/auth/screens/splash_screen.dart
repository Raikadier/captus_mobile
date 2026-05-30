import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.deliberate,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(AppDurations.splash);
    if (!mounted) return;

    final authAsync = ref.read(authProvider);

    if (authAsync.isLoading) {
      var waited = 0;
      while (ref.read(authProvider).isLoading && waited < 30) {
        await Future.delayed(AppDurations.quick);
        waited++;
      }
      if (!mounted) return;
    }

    final authState = ref.read(authProvider).asData?.value;
    if (authState?.isAuthenticated ?? false) {
      final role = authState!.role;
      if (role == 'superadmin') {
        context.go('/superadmin/dashboard');
      } else if (role == 'admin') {
        context.go('/admin/dashboard');
      } else {
        context.go(role == 'teacher' ? '/home/teacher' : '/home');
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      if (!mounted) return;
      context.go(seenOnboarding ? '/login' : '/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Opacity(
            opacity: _fadeAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.brandMd,
                    ),
                    child: const Center(
                      child: Text('🌵', style: TextStyle(fontSize: 52)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text('Captus', style: tt.displayMedium),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    'Organiza decisiones, no solo tareas.',
                    style: tt.bodyMedium!
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary.withAlpha(AppAlpha.a50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
