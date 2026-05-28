import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_animations.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/constants/app_shadows.dart';

/// Premium FloatingActionButton following Captus Design System v2.
///
/// Upgrades vs v1:
///   - Gradient fill (brand-500 → brand-600, 135°)
///   - Brand-tinted shadow (AppShadows.brandMd) — depth without heavy elevation
///   - Spring scale entrance (elasticOut, 420ms, 100ms post-build delay)
///   - Press feedback: scale down to 0.94 on tap, spring back on release
///
/// Usage:
/// ```dart
/// floatingActionButton: CaptusFab(
///   onPressed: () => context.push('/tasks/create'),
///   icon: Icons.add_rounded,
/// )
/// ```
class CaptusFab extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  const CaptusFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip,
  });

  @override
  State<CaptusFab> createState() => _CaptusFabState();
}

class _CaptusFabState extends State<CaptusFab>
    with TickerProviderStateMixin {
  // ── Entrance animation ──────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final Animation<double> _entranceScale;

  // ── Press animation ─────────────────────────────────────────────────────────
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();

    // Spring entrance: 0 → 1 with elasticOut overshoot
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.slow, // 420ms
    );
    _entranceScale = CurvedAnimation(
      parent: _entranceCtrl,
      curve: AppCurves.spring, // elasticOut
    );

    // Press: 1 → 0.94
    _pressCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.instant,       // 80ms press
      reverseDuration: AppDurations.quick,  // 120ms release
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _pressCtrl,
        curve: AppCurves.exit,
        reverseCurve: AppCurves.springShort,
      ),
    );

    // Delay entrance so screen content settles first
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    // Compose scales: entrance × press
    return ScaleTransition(
      scale: _entranceScale,
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressScale.value,
            child: child,
          );
        },
        child: Tooltip(
          message: widget.tooltip ?? '',
          child: GestureDetector(
            onTap: widget.onPressed,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                shape: BoxShape.circle,
                boxShadow: AppShadows.brandMd,
              ),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  widget.icon,
                  color: AppColors.textOnPrimary,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
