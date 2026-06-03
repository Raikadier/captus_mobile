import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/monitoring_service.dart';
import 'core/theme/app_theme.dart';
import 'core/env/env.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.initialize();
  await Env.load();

  // Firebase (Crashlytics + Analytics + FCM)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await MonitoringService.init();
    await FcmService.initialize();
  } catch (e) {
    debugPrint('[Firebase] Initialization failed: $e');
  }

  // Supabase — use SupabaseService so _initialized flag is set correctly.
  // Without the flag, any Dio interceptor that runs before this line would
  // throw "Supabase not initialized" and freeze the app on the splash screen.
  if (Env.hasSupabase) {
    try {
      await SupabaseService.initialize();
      debugPrint('[Supabase] Initialized OK');
    } catch (e) {
      debugPrint('[Supabase] Initialization failed: $e');
    }
  } else {
    debugPrint('[Supabase] Skipped — missing URL or key in .env');
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
      title: 'Captus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,   // lock to light until dark tokens exist
      routerConfig: router,
    );
  }
}
