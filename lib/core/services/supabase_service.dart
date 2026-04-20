import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env.dart';

/// Thin wrapper that initialises Supabase once and exposes the client.
///
/// Call [SupabaseService.initialize] in main() before runApp.
/// Then use [SupabaseService.client] anywhere in the app.
abstract class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  /// The global Supabase client.
  static SupabaseClient get client => Supabase.instance.client;

  /// Shortcut to the auth sub-client.
  static GoTrueClient get auth => client.auth;

  /// Current session (null when logged out).
  static Session? get currentSession => auth.currentSession;

  /// Current user (null when logged out).
  static User? get currentUser => auth.currentUser;
}
