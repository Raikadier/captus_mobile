import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/env/env.dart';
import 'core/router/app_router.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load .env variables first (other services depend on them).
  await Env.load();

  // 2. Initialise Supabase — auth + realtime subscriptions.
  await SupabaseService.initialize();

  // 3. Initialise Firebase — only needed for FCM (Phase 3).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      title: 'Captus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
