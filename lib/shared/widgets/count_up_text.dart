import 'package:flutter/material.dart';

/// Animates a number from 0 to [value] using an easeOut curve.
/// Used in statistics cards and profile metric tiles.
///
/// Usage:
/// ```dart
/// CountUpText(
///   value: stats.completedTasks,
///   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
/// )
///
/// // With suffix:
/// CountUpText(value: stats.streak, suffix: ' días')
///
/// // Percentage:
/// CountUpText(value: 85, suffix: '%')
/// ```
class CountUpText extends StatefulWidget {
  final num value;
  final TextStyle? style;
  final String suffix;
  final String prefix;
  final Duration duration;
  final int decimals;

  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.prefix = '',
    this.duration = const Duration(milliseconds: 800),
    this.decimals = 0,
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(CountUpText old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _format(double v) {
    if (widget.decimals == 0) return v.round().toString();
    return v.toStringAsFixed(widget.decimals);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final current = _anim.value * widget.value.toDouble();
        return Text(
          '${widget.prefix}${_format(current)}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
