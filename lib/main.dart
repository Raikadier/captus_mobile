import 'package:flutter/foundation.dart';
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

  // SQLite FFI solo en desktop. NO en web.
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await LocalStorageService.initialize();

  await Env.load();

  if (Env.hasSupabase) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );

      debugPrint('Supabase initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
    }
  } else {
    debugPrint('Running in offline/mock mode (Supabase credentials missing).');
  }

  await initializeDateFormatting('es');

  runApp(const ProviderScope(child: CaptusApp()));
}

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