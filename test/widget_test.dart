// Smoke tests: verify core theme and shared widgets build without crashing,
// without requiring Firebase or Supabase initialisation.
//
// Full provider/screen widget tests live under test/widgets/.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    testWidgets('dark theme sets Brightness.dark',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: Text('Captus')),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('primary colour is the cactus green #00C853',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.colorScheme.primary, const Color(0xFF00C853));
    });

    testWidgets('scaffold background is #121212',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });
  });

  group('MaterialApp basics', () {
    testWidgets('renders Text without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Hello Captus'))),
        ),
      );
      expect(find.text('Hello Captus'), findsOneWidget);
    });
  });
}
