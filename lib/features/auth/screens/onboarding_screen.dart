import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

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

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                  _currentPage == _pages.length - 1
                      ? 'Empezar ahora'
                      : 'Siguiente',
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_currentPage == _pages.length - 1)
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Crear cuenta nueva'),
              ),
            const SizedBox(height: 24),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.accentColor.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: page.accentColor.withAlpha(76), width: 2),
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == current ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == current ? AppColors.primary : AppColors.surface2,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
