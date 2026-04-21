import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

// ─── Background handler (must be top-level, not a class method) ──────────────
// Called when the app is terminated or in background.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by this point.
  debugPrint('[FCM] Background message: ${message.messageId}');
  // Optionally: parse message.data and update local state/DB here.
}

// ─── FCM Service ─────────────────────────────────────────────────────────────

/// Manages Firebase Cloud Messaging: permission, token registration,
/// and incoming message routing.
abstract class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _apiClient = ApiClient.instance;

  /// Call once after [Firebase.initializeApp] — wires up everything.
  static Future<void> initialize() async {
    // 1. Register background handler.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request permission (Android 13+ / iOS).
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Notifications denied by user.');
      return;
    }

    // 3. iOS foreground presentation options.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Get & register current token.
    await _registerToken();

    // 5. Listen for token refreshes (token can rotate over time).
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed');
      _sendTokenToBackend(newToken);
    });

    // 6. Handle messages when app is in the foreground.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 7. Handle notification tap when app was in background (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // 8. Check if app was launched from a notification (terminated state).
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }
  }

  // ── Token management ───────────────────────────────────────────────────────

  static Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Token: ${token.substring(0, 20)}...');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('[FCM] Failed to get token: $e');
    }
  }

  static Future<void> _sendTokenToBackend(String token) async {
    try {
      await _apiClient.post(
        '/notifications/device-token',
        data: {'token': token, 'platform': _platform},
      );
      debugPrint('[FCM] Token registered with backend');
    } catch (e) {
      // Non-fatal: token will be retried on next refresh
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  static String get _platform {
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    return 'unknown';
  }

  // ── Message handlers ───────────────────────────────────────────────────────

  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');
    // TODO (Phase 3): Show in-app notification banner via a Riverpod state.
    // e.g. ref.read(inAppNotificationProvider.notifier).show(message)
  }

  static void _handleNotificationOpen(RemoteMessage message) {
    debugPrint('[FCM] Notification opened: ${message.data}');
    // TODO (Phase 3): Deep-link navigation based on message.data['route']
    // e.g. router.push(message.data['route'] ?? '/notifications')
  }

  // ── Public helpers ─────────────────────────────────────────────────────────

  /// Deletes the FCM token (call on logout so the user stops receiving pushes).
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('[FCM] Token deleted');
    } catch (e) {
      debugPrint('[FCM] Failed to delete token: $e');
    }
  }
}
