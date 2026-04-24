import 'package:flutter/foundation.dart';

abstract class FcmService {
  static Future<void> initialize() async {
    debugPrint('[FCM] Notifications deshabilitadas en modo local.');
  }

  static Future<void> deleteToken() async {}
}
