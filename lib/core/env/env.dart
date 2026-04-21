import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Ignore if .env file doesn't exist
    }
  }

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://demo.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'demo-anon-key';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
