import 'package:flutter/material.dart';

/// Holds the root navigator key so non-widget code (FCM, deep links)
/// can imperatively navigate without a BuildContext.
class RouterService {
  RouterService._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Push a named route. Silently no-ops if navigator is not mounted.
  static void push(String path) {
    navigator?.pushNamed(path);
  }
}
