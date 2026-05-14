import 'package:flutter/material.dart';

/// Wraps a list of widgets so each one slides up and fades in with a
/// configurable stagger delay between items.
///
/// Usage — wrap any column of cards:
/// ```dart
/// StaggeredList(
///   staggerMs: 60,
///   children: tasks.map((t) => TaskCard(task: t)).toList(),
/// )
/// ```
///
/// Or use [StaggeredListView] for a scrollable list:
/// ```dart
/// StaggeredListView.builder(
///   itemCount: courses.length,
///   itemBuilder: (ctx, i) => CourseCard(course: courses[i]),
/// )
/// ```
class StaggeredList extends StatelessWidget {
  final List<Widget> children;

  /// Delay between each item's entrance in milliseconds. Default: 50ms.
  final int staggerMs;

  /// Total entrance duration per item. Default: 300ms.
  final int durationMs;

  /// Y-axis slide distance (in logical pixels). Default: 16.
  final double slideDistance;

  const StaggeredList({
    super.key,
    required this.children,
    this.staggerMs = 50,
    this.durationMs = 300,
    this.slideDistance = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < children.length; i++)
          _StaggeredItem(
            index: i,
            staggerMs: staggerMs,
            durationMs: durationMs,
            slideDistance: slideDistance,
            child: children[i],
          ),
      ],
    );
  }
}

/// A [ListView.builder] replacement that staggers each item's entrance.
class StaggeredListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int staggerMs;
  final int durationMs;
  final double slideDistance;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const StaggeredListView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerMs = 50,
    this.durationMs = 300,
    this.slideDistance = 16,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: padding,
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (ctx, i) => _StaggeredItem(
        index: i,
        staggerMs: staggerMs,
        durationMs: durationMs,
        slideDistance: slideDistance,
        child: itemBuilder(ctx, i),
      ),
    );
  }
}

/// A [GridView.builder] replacement that staggers each item's entrance.
class StaggeredGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final int staggerMs;
  final int durationMs;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const StaggeredGridView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.staggerMs = 60,
    this.durationMs = 250,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      gridDelegate: gridDelegate,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (ctx, i) => _StaggeredItem(
        index: i,
        staggerMs: staggerMs,
        durationMs: durationMs,
        slideDistance: 12,
        child: itemBuilder(ctx, i),
      ),
    );
  }
}

// ─── Internal animated item ───────────────────────────────────────────────────

class _StaggeredItem extends StatefulWidget {
  final int index;
  final int staggerMs;
  final int durationMs;
  final double slideDistance;
  final Widget child;

  const _StaggeredItem({
    required this.index,
    required this.staggerMs,
    required this.durationMs,
    required this.slideDistance,
    required this.child,
  });

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );

    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slide = Tween<double>(
      begin: widget.slideDistance,
      end: 0.0,
    ).animate(curved);

    // Stagger: each item starts after (index × staggerMs) ms
    final delay = widget.index * widget.staggerMs;
    Future.delayed(Duration(milliseconds: delay), () {
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
