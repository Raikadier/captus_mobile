import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env.dart';

/// Thin wrapper that initialises Supabase once and exposes the client.
///
/// Call [SupabaseService.initialize] in main() before runApp.
/// Then use [SupabaseService.client] anywhere in the app.
abstract class SupabaseService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    _initialized = true;
  }

  /// Whether Supabase has been successfully initialized.
  static bool get isInitialized => _initialized;

  /// The global Supabase client. Returns null if not yet initialized.
  static SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('[SupabaseService] client access failed: $e');
      return null;
    }
  }

  /// Shortcut to the auth sub-client. Returns null if not initialized.
  static GoTrueClient? get auth => client?.auth;

  /// Current session (null when logged out or not initialized).
  static Session? get currentSession => auth?.currentSession;

  /// Current user (null when logged out or not initialized).
  static User? get currentUser => auth?.currentUser;
}
