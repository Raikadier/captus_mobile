import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'api_client.dart';
import 'router_service.dart';

// ── Background handler (top-level, required by Firebase) ─────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised at this point.
  debugPrint('[FCM] Background message: ${message.messageId}');
}

// ── FCM Service ───────────────────────────────────────────────────────────────

abstract class FcmService {
  static final _messaging = FirebaseMessaging.instance;

  /// Wires up FCM after [Firebase.initializeApp].
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true, provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    await _registerToken();

    _messaging.onTokenRefresh.listen(_sendTokenToBackend);

    // Foreground → show in-app banner
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap → navigate
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Terminated tap → navigate
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNotificationOpen(initial);
  }

  // ── Token management ───────────────────────────────────────────────────────

  static Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _sendTokenToBackend(token);
    } catch (e) {
      debugPrint('[FCM] Failed to get token: $e');
    }
  }

  static Future<void> _sendTokenToBackend(String token) async {
    try {
      await ApiClient.instance.post(
        '/notifications/device-token',
        data: {'token': token, 'platform': _platform},
      );
    } catch (_) {
      // Non-fatal — will retry on next token refresh
    }
  }

  static String get _platform {
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    return 'unknown';
  }

  static Future<void> deleteToken() async {
    try { await _messaging.deleteToken(); } catch (_) {}
  }

  // ── Message handlers ───────────────────────────────────────────────────────

  /// Shows a dismissible banner at the top of the screen when the app is
  /// open and a push arrives.
  static void _handleForegroundMessage(RemoteMessage message) {
    final ctx = RouterService.navigator?.context;
    if (ctx == null) return;

    final title = message.notification?.title ?? 'Captus';
    final body  = message.notification?.body  ?? '';
    final route = message.data['route'] as String?;

    final overlay = Overlay.of(ctx);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _InAppBanner(
        title: title,
        body:  body,
        onTap: () {
          entry.remove();
          if (route != null) _navigate(ctx, route);
        },
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after 4 s
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }

  /// Navigates to the route embedded in the notification data payload.
  static void _handleNotificationOpen(RemoteMessage message) {
    final ctx   = RouterService.navigator?.context;
    final route = message.data['route'] as String?;
    if (ctx != null && route != null) _navigate(ctx, route);
  }

  static void _navigate(BuildContext ctx, String route) {
    try {
      GoRouter.of(ctx).push(route);
    } catch (_) {
      // GoRouter not mounted yet — fall back to /notifications
      GoRouter.of(ctx).go('/notifications');
    }
  }
}

// ── In-app notification banner ────────────────────────────────────────────────

class _InAppBanner extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppBanner({
    required this.title,
    required this.body,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Positioned(
      top: top + 8,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00C853).withAlpha(80)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_rounded,
                      size: 18, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (body.isNotEmpty)
                        Text(body,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFFAAAAAA)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: Color(0xFFAAAAAA)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
