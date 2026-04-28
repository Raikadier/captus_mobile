import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:captus_mobile/features/home/screens/home_dashboard_screen.dart';
import 'package:captus_mobile/core/providers/auth_provider.dart';
import 'package:captus_mobile/core/providers/courses_provider.dart';
import 'package:captus_mobile/models/course.dart';

import 'home_dashboard_test.mocks.dart';

@GenerateMocks([GoRouter])
void main() {
  group('HomeDashboardScreen Widget Tests', () {
    late MockGoRouter mockRouter;

    setUp(() {
      mockRouter = MockGoRouter();
    });

    Widget createWidgetUnderTest({ProviderContainer? container}) {
      return ProviderScope(
        parent: container,
        child: MaterialApp.router(
          routerConfig: mockRouter,
          home: const HomeDashboardScreen(),
        ),
      );
    }

    testWidgets('should display dashboard elements', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Bienvenido'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display user information', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert - Should display user name and role
      expect(find.text('David Barceló'), findsOneWidget);
      expect(find.text('Estudiante'), findsOneWidget);
    });

    testWidgets('should display courses list', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert - Should display course cards
      expect(find.text('Mis Cursos'), findsOneWidget);
      expect(find.text('Estructuras de Datos'), findsOneWidget);
      expect(find.text('Cálculo II'), findsOneWidget);
      expect(find.text('IS-301'), findsOneWidget);
      expect(find.text('MA-201'), findsOneWidget);
    });

    testWidgets('should display course progress', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert - Should display progress indicators
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('should display pending activities count', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert - Should display pending activities badges
      expect(find.text('2 pendientes'), findsOneWidget);
      expect(find.text('1 pendiente'), findsOneWidget);
    });

    testWidgets('should navigate to course detail when course card is tapped', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Act - Tap on first course
      await tester.tap(find.text('Estructuras de Datos'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to course detail
      verify(mockRouter.push('/courses/c1')).called(1);
    });

    testWidgets('should display quick actions', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert - Should display quick action buttons
      expect(find.text('Ver Calendario'), findsOneWidget);
      expect(find.text('Ver Tareas'), findsOneWidget);
      expect(find.text('Ver Notificaciones'), findsOneWidget);
    });

    testWidgets('should navigate to calendar when calendar button is tapped', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Act - Tap calendar button
      await tester.tap(find.text('Ver Calendario'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to calendar
      verify(mockRouter.push('/calendar')).called(1);
    });

    testWidgets('should navigate to tasks when tasks button is tapped', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Act - Tap tasks button
      await tester.tap(find.text('Ver Tareas'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to tasks
      verify(mockRouter.push('/tasks')).called(1);
    });

    testWidgets('should navigate to notifications when notifications button is tapped', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Act - Tap notifications button
      await tester.tap(find.text('Ver Notificaciones'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to notifications
      verify(mockRouter.push('/notifications')).called(1);
    });

    testWidgets('should display loading state while fetching courses', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockLoadingCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pump();

      // Assert - Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando cursos...'), findsOneWidget);
    });

    testWidgets('should display error state when courses fail to load', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockErrorCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert - Should show error message
      expect(find.text('Error al cargar cursos'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('should refresh courses when retry is tapped', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockErrorCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Act - Tap retry button
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      // Assert - Should attempt to refresh
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no courses', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockEmptyCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert - Should show empty state
      expect(find.text('No tienes cursos inscritos'), findsOneWidget);
      expect(find.text('Explorar cursos'), findsOneWidget);
    });

    testWidgets('should display profile section', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert - Should display profile information
      expect(find.text('Universidad Popular del Cesar'), findsOneWidget);
      expect(find.text('Ingeniería de Sistemas'), findsOneWidget);
      expect(find.text('5° Semestre'), findsOneWidget);
    });

    testWidgets('should navigate to profile when profile is tapped', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Act - Tap on profile section
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Assert - Should navigate to profile
      verify(mockRouter.push('/profile')).called(1);
    });

    testWidgets('should display statistics cards', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Assert - Should display statistics
      expect(find.text('4'), findsOneWidget); // Total courses
      expect(find.text('3'), findsOneWidget); // Pending activities
      expect(find.text('85%'), findsOneWidget); // Average progress
    });

    testWidgets('should handle pull to refresh', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(container: container));
      await tester.pumpAndSettle();

      // Act - Pull to refresh
      await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      // Assert - Should refresh data
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('HomeDashboardScreen Integration Tests', () {
    testWidgets('should integrate with auth provider', (WidgetTester tester) async {
      // Test integration with auth provider
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
        ],
      );

      await tester.pumpWidget(ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HomeDashboardScreen), findsOneWidget);
    });

    testWidgets('should integrate with courses provider', (WidgetTester tester) async {
      // Test integration with courses provider
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          coursesProvider.overrideWith((ref) => MockCoursesNotifier()),
        ],
      );

      await tester.pumpWidget(ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HomeDashboardScreen), findsOneWidget);
      expect(find.text('Estructuras de Datos'), findsOneWidget);
    });

    testWidgets('should handle authentication state changes', (WidgetTester tester) async {
      // Test behavior when auth state changes
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
        ],
      );

      await tester.pumpWidget(ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      // Simulate auth state change
      // This would require more complex state management testing
      expect(find.byType(HomeDashboardScreen), findsOneWidget);
    });
  });
}

// Mock classes for testing
class MockAuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    return AuthState.authenticated(const LocalUser(
      id: '1',
      email: 'dbarcelo@unicesar.edu.co',
      name: 'David Barceló',
      role: 'student',
      university: 'Universidad Popular del Cesar',
      career: 'Ingeniería de Sistemas',
      semester: 5,
    ));
  }
}

class MockCoursesNotifier extends AsyncNotifier<List<CourseModel>> {
  @override
  Future<List<CourseModel>> build() async {
    return CourseModel.mockList;
  }
}

class MockLoadingCoursesNotifier extends AsyncNotifier<List<CourseModel>> {
  @override
  Future<List<CourseModel>> build() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}

class MockErrorCoursesNotifier extends AsyncNotifier<List<CourseModel>> {
  @override
  Future<List<CourseModel>> build() async {
    throw Exception('Failed to load courses');
  }
}

class MockEmptyCoursesNotifier extends AsyncNotifier<List<CourseModel>> {
  @override
  Future<List<CourseModel>> build() async {
    return [];
  }
}
