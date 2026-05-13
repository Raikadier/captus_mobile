import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/monitoring_service.dart';
import 'core/theme/app_theme.dart';
import 'core/env/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.initialize();
  await Env.load();

  // Firebase (Crashlytics + Analytics + FCM)
  try {
    await Firebase.initializeApp();
    await MonitoringService.init();
    await FcmService.initialize();
  } catch (e) {
    debugPrint('[Firebase] Initialization failed: $e');
  }

  // Supabase
  if (Env.hasSupabase) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('[Supabase] Initialization failed: $e');
    }
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
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
