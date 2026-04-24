import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/services/local_storage_service.dart';

/// Modelo para una página de onboarding
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Pantalla mejorada de onboarding con 5 páginas y animaciones
class EnhancedOnboardingScreen extends ConsumerStatefulWidget {
  const EnhancedOnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EnhancedOnboardingScreen> createState() =>
      _EnhancedOnboardingScreenState();
}

class _EnhancedOnboardingScreenState
    extends ConsumerState<EnhancedOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: '📚 Bienvenido a Captus',
      description:
          'Tu plataforma inteligente de gestión académica con IA integrada',
      icon: Icons.school,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: '📸 Captura tu Aprendizaje',
      description:
          'Toma fotos de tus tareas, escanea códigos QR y accede a contenido',
      icon: Icons.camera_alt,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: '📊 Visualiza tu Progreso',
      description:
          'Analiza tus estadísticas y mejora con insights visuales en tiempo real',
      icon: Icons.bar_chart,
      color: Colors.green,
    ),
    OnboardingPage(
      title: '🤖 IA Asistente 24/7',
      description:
          'Resuelve dudas y obtén ayuda personalizada en tus cursos',
      icon: Icons.smart_toy,
      color: Colors.purple,
    ),
    OnboardingPage(
      title: '🚀 ¡Listo para Empezar!',
      description:
          'Únete a tus cursos y comienza a potenciar tu aprendizaje hoy',
      icon: Icons.rocket_launch,
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await LocalStorageService.instance.setBool('onboardingCompleted', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView con páginas de onboarding
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(
                page: pages[index],
                pageIndex: index,
              );
            },
          ),

          // Indicador de páginas en la parte inferior
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: pages.length,
                effect: WormEffect(
                  activeDotColor: pages[_currentPage].color,
                  dotColor: Colors.grey[300]!,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
            ),
          ),

          // Botones de navegación
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón Atrás
                if (_currentPage > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Atrás'),
                  )
                else
                  const SizedBox(width: 100),

                // Botón Siguiente o Finalizar
                ElevatedButton.icon(
                  onPressed: () {
                    if (_currentPage == pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: Icon(
                    _currentPage == pages.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    _currentPage == pages.length - 1 ? 'Finalizar' : 'Siguiente',
                  ),
                ),
              ],
            ),
          ),

          // Botón Saltar (solo si no es la última página)
          if (_currentPage < pages.length - 1)
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Saltar'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget para cada página del onboarding
class OnboardingPageWidget extends StatefulWidget {
  final OnboardingPage page;
  final int pageIndex;

  const OnboardingPageWidget({
    Key? key,
    required this.page,
    required this.pageIndex,
  }) : super(key: key);

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.page.color.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono animado
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: widget.page.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.page.icon,
                  size: 80,
                  color: widget.page.color,
                ),
              ),
              const SizedBox(height: 48),

              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.page.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.page.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
