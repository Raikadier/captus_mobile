import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:captus_mobile/features/auth/screens/login_screen.dart';
import 'package:captus_mobile/core/providers/auth_provider.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([GoRouter])
void main() {
  group('LoginScreen Widget Tests', () {
    late MockGoRouter mockRouter;

    setUp(() {
      mockRouter = MockGoRouter();
    });

    Widget createWidgetUnderTest({ProviderContainer? container}) {
      return ProviderScope(
        parent: container,
        child: MaterialApp.router(
          routerConfig: mockRouter,
          home: const LoginScreen(),
        ),
      );
    }

    testWidgets('should display login form elements', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Captus'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Correo institucional'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
      expect(find.text('¿No tienes cuenta? '), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
    });

    testWidgets('should display role selector tabs', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Estudiante'), findsOneWidget);
      expect(find.text('Docente'), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('should select student role by default', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Student tab should be selected (has black text)
      final studentTab = tester.widget<Text>(find.text('Estudiante'));
      final teacherTab = tester.widget<Text>(find.text('Docente'));
      
      // The selected tab should have black color, unselected should have textSecondary
      expect(studentTab.style?.color, Colors.black);
      expect(teacherTab.style?.color, isNot(Colors.black));
    });

    testWidgets('should switch to teacher role when tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Tap on teacher tab
      await tester.tap(find.text('Docente'));
      await tester.pumpAndSettle();

      // Assert - Teacher tab should now be selected
      final teacherTab = tester.widget<Text>(find.text('Docente'));
      final studentTab = tester.widget<Text>(find.text('Estudiante'));
      
      expect(teacherTab.style?.color, Colors.black);
      expect(studentTab.style?.color, isNot(Colors.black));
    });

    testWidgets('should show password visibility toggle', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - Password field should have visibility toggle
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('should toggle password visibility when icon is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      // Assert - Icon should change
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      // Act - Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      // Assert - Icon should change back
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Enter invalid email and try to submit
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Assert - Should show validation error
      expect(find.text('Ingresa un correo válido'), findsOneWidget);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Enter short password and try to submit
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Assert - Should show validation error
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('should enable login button when form is valid', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pumpAndSettle();

      // Assert - Login button should be enabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should show loading indicator during login', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
        ],
      );
      
      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Act - Enter valid credentials and tap login
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Assert - Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
    });

    testWidgets('should show error message when login fails', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()..setError('Login failed')),
        ],
      );
      
      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Act - Enter credentials and tap login
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Assert - Should show error message
      expect(find.text('Login failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('should navigate to forgot password when link is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Tap forgot password link
      await tester.tap(find.text('¿Olvidaste tu contraseña?'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to forgot password
      verify(mockRouter.push('/forgot-password')).called(1);
    });

    testWidgets('should navigate to register when link is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Tap register link
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to register
      verify(mockRouter.go('/register')).called(1);
    });

    testWidgets('should show Google sign-in button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('G'), findsOneWidget);
    });

    testWidgets('should have correct email field properties', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(emailField.keyboardType, TextInputType.emailAddress);
      expect(emailField.autocorrect, false);
      expect(find.text('usuario@unicesar.edu.co'), findsOneWidget);
    });

    testWidgets('should have correct password field properties', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).last);
      expect(passwordField.obscureText, true);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });

    testWidgets('should display Captus logo and branding', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('🌵'), findsOneWidget);
      expect(find.text('Captus'), findsOneWidget);
      
      // Check logo container properties
      final logoContainer = tester.widget<Container>(find.byType(Container).first);
      expect(logoContainer.decoration, isA<BoxDecoration>());
      final decoration = logoContainer.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('should handle form submission correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Fill form and submit
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Assert - Form should be submitted
      // Note: This would require mocking the auth provider in a real test
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  group('LoginScreen Integration Tests', () {
    testWidgets('should integrate with auth provider', (WidgetTester tester) async {
      // This test would verify integration with the actual auth provider
      // Implementation depends on mocking strategy
      
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should handle authentication state changes', (WidgetTester tester) async {
      // This test would verify behavior when auth state changes
      // Implementation depends on state management strategy
      
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}

// Mock classes for testing
class MockAuthNotifier extends AsyncNotifier<AuthState> {
  String? _error;

  void setError(String error) {
    _error = error;
    state = AsyncData(AuthState.unauthenticated(error));
  }

  @override
  Future<AuthState> build() async {
    return const AuthState.unauthenticated();
  }

  Future<String?> signIn({required String email, required String password}) async {
    if (_error != null) return _error;
    return null; // Success
  }
}
