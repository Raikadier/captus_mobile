import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/env/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. Initialize SQLite FFI for desktop (Windows/Linux/macOS)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // 1. Initialize local storage
  await LocalStorageService.initialize();

  // 2. Load environment variables
  await Env.load();

  // 3. Initialize Supabase if keys are present
  if (Env.hasSupabase) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      await Supabase.instance.client.auth.signOut();
      
      debugPrint('Supabase initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
    }
  } else {
    debugPrint('Running in offline/mock mode (Supabase credentials missing).');
  }

  // 4. Spanish locale data for date formatting.
  await initializeDateFormatting('es');

  runApp(const ProviderScope(child: CaptusApp()));
}

/// Root widget. Wraps itself in a [ConsumerWidget] so [createRouter] can
/// receive the Riverpod [ref] and attach the auth-refresh listener.
class CaptusApp extends ConsumerWidget {
  const CaptusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createRouter(ref);
    return MaterialApp.router(
      title: 'Captus_mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
