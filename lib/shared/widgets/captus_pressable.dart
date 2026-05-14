import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_animations.dart';

/// A tappable wrapper that applies a scale-down press animation
/// following the Captus design system (scale 0.97, 80ms instant).
///
/// Replaces bare [GestureDetector] for any interactive card, button,
/// or list item that needs tactile press feedback.
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

  /// Scale factor at maximum press depth. Default: 0.97 (design spec).
  final double pressScale;

  /// Whether to trigger a light haptic when pressed.
  final bool haptic;

  const CaptusPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressScale = 0.97,
    this.haptic = false,
  });

  @override
  State<CaptusPressable> createState() => _CaptusPressableState();
}

class _CaptusPressableState extends State<CaptusPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.instant,      // 80ms press
      reverseDuration: AppDurations.fast,  // 150ms release
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.exit,    // Accelerate into press
      reverseCurve: AppCurves.enter, // Decelerate on release
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
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
