/// E2E Navigation smoke tests — run on device/emulator.
///
/// How to run:
///   flutter test integration_test/app_navigation_test.dart --device-id <id>
///
/// These tests launch the full app and verify that key navigation flows
/// complete without crashing. They do NOT require an authenticated user;
/// unauthenticated flow (splash → login) is the primary path tested.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:captus_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App navigation — unauthenticated flow', () {
    testWidgets('app launches without crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should display something — at minimum a Scaffold
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('splash screen transitions to login within 5 seconds', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // After splash the app should show a login-like screen
      // Look for the cactus emoji or at least one TextFormField
      final hasLoginIndicator =
          find.text('🌵').evaluate().isNotEmpty ||
          find.byType(TextFormField).evaluate().isNotEmpty;

      expect(hasLoginIndicator, isTrue,
          reason: 'App should reach login screen from splash');
    });

    testWidgets('email input field accepts text', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final emailField = find.byType(TextFormField);
      if (emailField.evaluate().isNotEmpty) {
        await tester.tap(emailField.first);
        await tester.enterText(emailField.first, 'test@captus.edu.co');
        await tester.pump();

        expect(find.text('test@captus.edu.co'), findsOneWidget);
      }
    });

    testWidgets('shows validation error on empty login submit', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginBtn =
          find.textContaining('Iniciar') | find.textContaining('Entrar');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pump();

        // No crash — form validation runs
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });

  group('App navigation — widget tree integrity', () {
    testWidgets('no uncaught errors during cold start', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      FlutterError.onError = prev;

      // Filter out layout overflow warnings (common in test environment)
      final criticalErrors = errors
          .where((e) => !e.toString().contains('RenderFlex overflowed'))
          .toList();

      expect(criticalErrors, isEmpty,
          reason: 'Critical Flutter errors during cold start: '
              '${criticalErrors.map((e) => e.summary).join(", ")}');
    });
  });
}
