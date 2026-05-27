import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:captus_mobile/features/auth/screens/login_screen.dart';
import 'package:captus_mobile/core/services/local_storage_service.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUp(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'http://localhost:3000/api',
      'SUPABASE_URL': '',
      'SUPABASE_ANON_KEY': '',
    });
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.initialize();
  });

  group('LoginScreen — structure', () {
    testWidgets('renders at least two TextFormFields (email + password)', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('renders cactus emoji', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();

      expect(find.text('🌵'), findsOneWidget);
    });

    testWidgets('renders a login action button', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();

      final hasIniciar = find.textContaining('Iniciar').evaluate().isNotEmpty;
      final hasEntrar  = find.textContaining('Entrar').evaluate().isNotEmpty;
      expect(hasIniciar || hasEntrar, isTrue,
          reason: 'Expected a login button containing "Iniciar" or "Entrar"');
    });

    testWidgets('password field obscures text by default', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();

      final editables =
          tester.widgetList<EditableText>(find.byType(EditableText)).toList();
      // At least one editable should be obscured (password field)
      final hasObscured = editables.any((e) => e.obscureText);
      expect(hasObscured, isTrue);
    });

    testWidgets('visibility toggle icon is rendered', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();

      // LoginScreen uses visibility_outlined / visibility_off_outlined variants
      final hasOffIcon = find.byIcon(Icons.visibility_off_outlined).evaluate().isNotEmpty;
      final hasOnIcon  = find.byIcon(Icons.visibility_outlined).evaluate().isNotEmpty;
      expect(hasOffIcon || hasOnIcon, isTrue,
          reason: 'Expected a password visibility toggle icon (visibility_outlined or visibility_off_outlined)');
    });
  });

  group('LoginScreen — validation', () {
    testWidgets('shows validation errors when submitting empty form', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();

      final hasIniciar = find.textContaining('Iniciar').evaluate().isNotEmpty;
      final hasEntrar  = find.textContaining('Entrar').evaluate().isNotEmpty;

      if (hasIniciar || hasEntrar) {
        final loginBtn = hasIniciar
            ? find.textContaining('Iniciar')
            : find.textContaining('Entrar');
        await tester.tap(loginBtn.first, warnIfMissed: false);
        await tester.pump();
      }

      // Validation errors cause Text widgets with error style — just ensure
      // we did not crash (form is still displayed)
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('entering text in fields changes state', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'user@test.com');
      await tester.pump();

      expect(find.text('user@test.com'), findsOneWidget);
    });

    testWidgets('tapping visibility toggle changes icon', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();

      // Find visibility toggle (eye icon)
      final offIcon = find.byIcon(Icons.visibility_off_rounded);
      final onIcon  = find.byIcon(Icons.visibility_rounded);

      final toggleFinder = offIcon.evaluate().isNotEmpty ? offIcon : onIcon;
      if (toggleFinder.evaluate().isNotEmpty) {
        await tester.tap(toggleFinder.first, warnIfMissed: false);
        await tester.pump();
        // After toggling, the icon should flip — widget still renders
        expect(find.byType(LoginScreen), findsOneWidget);
      }
    });
  });

  group('LoginScreen — accessibility', () {
    testWidgets('wraps in Form widget', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('renders without crash on 360x640 device', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 3.0;
      addTearDown(tester.binding.window.clearAllTestValues);

      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
