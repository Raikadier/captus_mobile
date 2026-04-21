import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local storage
  await LocalStorageService.initialize();

  // 2. Spanish locale data for date formatting.
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
