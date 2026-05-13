import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Central monitoring façade — wraps Crashlytics + Analytics.
///
/// All methods are no-ops when Firebase is not initialised (e.g. dev without
/// google-services.json). This prevents crashes in CI / desktop environments.
class MonitoringService {
  MonitoringService._();

  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static bool _ready = false;

  // ── Setup ─────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    try {
      _analytics   = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Route Flutter framework errors to Crashlytics
      FlutterError.onError = _crashlytics!.recordFlutterFatalError;

      // Route async/platform errors not caught by Flutter's framework
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics!.recordError(error, stack, fatal: true);
        return true;
      };

      // Disable Crashlytics in debug builds to reduce noise
      await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);

      _ready = true;
    } catch (e) {
      // Firebase not configured — monitoring silently disabled
      debugPrint('[Monitoring] Firebase not available: $e');
    }
  }

  // ── User identity ─────────────────────────────────────────────────────────

  /// Call after a successful login to associate events with the user.
  static Future<void> setUser(String userId, {String? role}) async {
    if (!_ready) return;
    try {
      await _crashlytics?.setUserIdentifier(userId);
      await _analytics?.setUserId(id: userId);
      if (role != null) {
        await _analytics?.setUserProperty(name: 'role', value: role);
      }
    } catch (_) {}
  }

  /// Call on logout to remove the user identity from future events.
  static Future<void> clearUser() async {
    if (!_ready) return;
    try {
      await _crashlytics?.setUserIdentifier('');
      await _analytics?.setUserId(id: null);
    } catch (_) {}
  }

  // ── Analytics events ──────────────────────────────────────────────────────

  static Future<void> logLogin({required String method}) async {
    if (!_ready) return;
    try { await _analytics?.logLogin(loginMethod: method); } catch (_) {}
  }

  static Future<void> logTaskCreated() async {
    if (!_ready) return;
    try { await _analytics?.logEvent(name: 'task_created'); } catch (_) {}
  }

  static Future<void> logTaskCompleted() async {
    if (!_ready) return;
    try { await _analytics?.logEvent(name: 'task_completed'); } catch (_) {}
  }

  static Future<void> logAiMessageSent() async {
    if (!_ready) return;
    try { await _analytics?.logEvent(name: 'ai_message_sent'); } catch (_) {}
  }

  static Future<void> logGroupJoined() async {
    if (!_ready) return;
    try { await _analytics?.logEvent(name: 'group_joined'); } catch (_) {}
  }

  static Future<void> logScreenView(String screenName) async {
    if (!_ready) return;
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (_) {}
  }

  // ── Error reporting ───────────────────────────────────────────────────────

  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) async {
    if (!_ready) return;
    try {
      await _crashlytics?.recordError(error, stack, fatal: fatal);
    } catch (_) {}
  }

  /// Convenience getter for the Analytics navigator observer.
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics ?? FirebaseAnalytics.instance);
}
