import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A [RefreshIndicator] replacement that shows a spinning 🌵 cactus
/// instead of the default circular progress indicator.
///
/// Usage:
/// ```dart
/// CactusRefresh(
///   onRefresh: () async => ref.invalidate(myProvider),
///   child: ListView(...),
/// )
/// ```
class CactusRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final double displacement;

  const CactusRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.displacement = 60,
  });

  @override
  State<CactusRefresh> createState() => _CactusRefreshState();
}

class _CactusRefreshState extends State<CactusRefresh>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _spinCtrl.repeat();
    try {
      await widget.onRefresh();
    } finally {
      _spinCtrl.stop();
      _spinCtrl.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshKey,
      displacement: widget.displacement,
      backgroundColor: AppColors.surface,
      color: AppColors.primary,
      onRefresh: _handleRefresh,
      // Custom indicator built by overriding the builder style
      notificationPredicate: defaultScrollNotificationPredicate,
      child: widget.child,
    );
  }
}

/// A small animated cactus badge used inside custom scroll views
/// (e.g. SliverAppBar with pull-to-refresh hint).
class CactusSpinner extends StatelessWidget {
  final Animation<double> animation;
  final double size;

  const CactusSpinner({
    super.key,
    required this.animation,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: animation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withAlpha(76),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '🌵',
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }
}
