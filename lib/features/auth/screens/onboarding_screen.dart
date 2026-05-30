import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}

const _pages = [
  _OnboardingPage(
    emoji: '📋',
    title: 'Tareas con inteligencia',
    subtitle:
        'La IA prioriza tus pendientes, genera subtareas y te recuerda lo que importa — antes de que sea tarde.',
    accentColor: AppColors.primary,
  ),
  _OnboardingPage(
    emoji: '📅',
    title: 'Calendario que piensa',
    subtitle:
        'Visualiza todas tus entregas en un solo lugar. El asistente sabe cuándo tienes tiempo libre y te ayuda a usarlo.',
    accentColor: AppColors.info,
  ),
  _OnboardingPage(
    emoji: '👥',
    title: 'Grupos sin caos',
    subtitle:
        'Coordina proyectos académicos sin depender de WhatsApp. Todo en un solo lugar, con contexto.',
    accentColor: AppColors.warning,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.standard,
        curve: AppCurves.standard,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_onboarding', true);
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      restorationId: 'onboarding_page',
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seen_onboarding', true);
                  if (!context.mounted) return;
                  context.go('/login');
                },
                child: const Text('Omitir'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingPageWidget(page: _pages[i]),
              ),
            ),
            _DotsIndicator(count: _pages.length, current: _currentPage),
            const SizedBox(height: AppSpacing.s6),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageMargin),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                  _currentPage == _pages.length - 1
                      ? 'Empezar ahora'
                      : 'Siguiente',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            if (_currentPage == _pages.length - 1)
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Crear cuenta nueva'),
              ),
            const SizedBox(height: AppSpacing.s6),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.accentColor.withAlpha(AppAlpha.a10),
              shape: BoxShape.circle,
              border: Border.all(
                  color: page.accentColor.withAlpha(AppAlpha.a30), width: 2),
            ),
            child: Center(
              child: Text(page.emoji,
                  style: const TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          Text(
            page.title,
            style: tt.headlineLarge!.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            page.subtitle,
            style: tt.bodyMedium!.copyWith(
                color: AppColors.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
          width: i == current ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == current ? AppColors.primary : AppColors.surface2,
            borderRadius: BorderRadius.circular(AppRadius.r1),
          ),
        );
      }),
    );
  }
}
