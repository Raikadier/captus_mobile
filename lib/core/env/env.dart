import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to environment variables.
/// All values are read once at startup via [dotenv].
///
/// Usage:
///   await Env.load();          // call in main() before runApp
///   print(Env.supabaseUrl);
abstract class Env {
  static Future<void> load() => dotenv.load(fileName: '.env');

  // ── Supabase ──────────────────────────────────────────────────────────────
  static String get supabaseUrl => _require('SUPABASE_URL');
  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  // ── Backend API ───────────────────────────────────────────────────────────
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  // ── Gemini (Phase 2) ──────────────────────────────────────────────────────
  static String get geminiApiKey => _require('GEMINI_API_KEY');

  // ─────────────────────────────────────────────────────────────────────────
  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required env variable: $key\n'
        'Copy .env.example to .env and fill in the values.',
      );
    }
    return value;
  }
}
