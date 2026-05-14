import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A FloatingActionButton that enters the screen with a spring scale
/// animation following the Captus design system (scale 0→1, elasticOut,
/// 400ms, 100ms delay after screen build).
///
/// Drop-in replacement for [FloatingActionButton] in any Scaffold.
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
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CaptusFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<CaptusFab> createState() => _CaptusFabState();
}

class _CaptusFabState extends State<CaptusFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.elasticOut, // natural spring bounce
    );
    // Small delay so the screen content renders first
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        backgroundColor: widget.backgroundColor ?? AppColors.primary,
        foregroundColor: widget.foregroundColor ?? AppColors.textOnPrimary,
        child: Icon(widget.icon),
      ),
    );
  }
}
