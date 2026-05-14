import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Logs the user out automatically after [timeout] of inactivity.
///
/// Usage — wrap your authenticated shell with [InactivityDetector]:
/// ```dart
/// InactivityDetector(child: MainShell(...))
/// ```
///
/// Call [InactivityService.reset()] from any gesture/tap handler to keep
/// the session alive, or rely on [InactivityDetector] which does it
/// automatically for all pointer events.
class InactivityService {
  static const _timeout = Duration(minutes: 30);

  static WidgetRef? _ref;
  static Timer? _timer;

  static void init(WidgetRef ref) {
    _ref = ref;
    reset();
  }

  static void reset() {
    _timer?.cancel();
    _timer = Timer(_timeout, _onTimeout);
  }

  static void dispose() {
    _timer?.cancel();
    _timer = null;
    _ref = null;
  }

  static void _onTimeout() {
    _ref?.read(authProvider.notifier).signOut();
  }
}

/// Wraps [child] in a [Listener] that resets the inactivity timer on every
/// pointer-down event (taps, scrolls, drags).
class InactivityDetector extends ConsumerStatefulWidget {
  final Widget child;
  const InactivityDetector({super.key, required this.child});

  @override
  ConsumerState<InactivityDetector> createState() => _InactivityDetectorState();
}

class _InactivityDetectorState extends ConsumerState<InactivityDetector> {
  @override
  void initState() {
    super.initState();
    InactivityService.init(ref);
  }

  @override
  void dispose() {
    InactivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => InactivityService.reset(),
      child: widget.child,
    );
  }
}
