import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_animations.dart';

/// Premium tappable wrapper following Captus Design System v2.
///
/// Applies simultaneous scale + opacity press animation for a tactile,
/// natural feel. Uses design-system spring curve for the release bounce.
///
/// Press state:  scale(0.97) + opacity(0.90) — instant/exit (80ms)
/// Release state: scale(1.0)  + opacity(1.0)  — quick/springShort (120ms)
///
/// Replaces bare [GestureDetector] for interactive cards, list items,
/// and any tappable surface that needs premium feedback.
///
/// Usage:
/// ```dart
/// CaptusPressable(
///   onTap: () => doSomething(),
///   child: MyCard(),
/// )
/// ```
class CaptusPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scale factor at maximum press depth. Default: [AppMotion.pressScale] = 0.97.
  final double pressScale;

  /// Opacity at maximum press depth. Default: [AppMotion.pressOpacity] = 0.90.
  final double pressOpacity;

  /// Whether to trigger a light haptic on tap-down.
  final bool haptic;

  const CaptusPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressScale   = AppMotion.pressScale,
    this.pressOpacity = AppMotion.pressOpacity,
    this.haptic       = false,
  });

  @override
  State<CaptusPressable> createState() => _CaptusPressableState();
}

class _CaptusPressableState extends State<CaptusPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.pressDuration,    // 80ms — instant
      reverseDuration: AppMotion.releaseDuration, // 120ms — quick
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppMotion.pressCurve,   // easeIn — accelerate into press
      reverseCurve: AppMotion.releaseCurve.flipped, // springShort — bounce back
    ));

    _opacity = Tween<double>(
      begin: 1.0,
      end: widget.pressOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppMotion.pressCurve,
      reverseCurve: AppCurves.smooth,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.haptic) HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null || widget.onLongPress != null;
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: interactive ? _onTapDown : null,
      onTapUp:   interactive ? _onTapUp   : null,
      onTapCancel: interactive ? _onTapCancel : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
