import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:captus_mobile/core/providers/auth_provider.dart';
import 'package:captus_mobile/models/user.dart';
import 'package:captus_mobile/models/course.dart';
import 'package:captus_mobile/models/task.dart';

import 'mock_data.dart';

/// Test helper utilities for captus_mobile testing
class TestHelpers {
  // Widget testing helpers
  static Widget createTestWidget({required Widget child, ProviderContainer? container}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  static Widget createTestWidgetWithRouter({
    required Widget child,
    ProviderContainer? container,
  }) {
    return ProviderScope(
      parent: container,
      child: MaterialApp.router(
        routerConfig: _createTestRouter(),
        routeInformationProvider: _createTestRouter().routeInformationProvider,
      ),
    );
  }

  // Provider testing helpers
  static ProviderContainer createProviderContainer({
    LocalUser? user,
    List<CourseModel>? courses,
    List<TaskModel>? tasks,
  }) {
    return ProviderContainer(
      overrides: [
        if (user != null)
          authProvider.overrideWith((ref) => MockAuthNotifier(user)),
        // Add other provider overrides as needed
      ],
    );
  }

  // Mock data helpers
  static LocalUser createMockUser({
    String id = 'test_user',
    String email = 'test@example.com',
    String name = 'Test User',
    String role = 'student',
    String? university,
    String? career,
    int? semester,
  }) {
    return LocalUser(
      id: id,
      email: email,
      name: name,
      role: role,
      university: university,
      career: career,
      semester: semester,
    );
  }

  static CourseModel createMockCourse({
    String id = 'test_course',
    String name = 'Test Course',
    String code = 'TC101',
    String teacherName = 'Test Teacher',
    int colorIndex = 0,
    double progress = 0.5,
    int pendingActivities = 1,
  }) {
    return CourseModel(
      id: id,
      name: name,
      code: code,
      teacherName: teacherName,
      colorIndex: colorIndex,
      progress: progress,
      pendingActivities: pendingActivities,
    );
  }

  static TaskModel createMockTask({
    String id = 'test_task',
    String title = 'Test Task',
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    TaskStatus status = TaskStatus.pending,
    String? courseId,
    String? courseName,
  }) {
    return TaskModel(
      id: id,
      title: title,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
      priority: priority,
      status: status,
      courseId: courseId,
      courseName: courseName,
    );
  }

  // Form testing helpers
  static Future<void> fillLoginForm(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byKey(const Key('email_field')), email);
    await tester.enterText(find.byKey(const Key('password_field')), password);
  }

  static Future<void> submitForm(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pumpAndSettle();
  }

  // Navigation testing helpers
  static Future<void> tapNavigationItem(
    WidgetTester tester, {
    required String label,
  }) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  // Async testing helpers
  static Future<void> waitForLoading(WidgetTester tester) async {
    await tester.pump();
    while (tester.widgetList(find.byType(CircularProgressIndicator)).isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  static Future<void> waitForError(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  // Assertion helpers
  static void expectTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  static void expectTextDoesNotExist(String text) {
    expect(find.text(text), findsNothing);
  }

  static void expectWidgetExists<T extends Widget>() {
    expect(find.byType(T), findsAtLeastNWidgets(1));
  }

  static void expectWidgetDoesNotExist<T extends Widget>() {
    expect(find.byType(T), findsNothing);
  }

  static void expectButtonEnabled(String text) {
    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, text));
    expect(button.onPressed, isNotNull);
  }

  static void expectButtonDisabled(String text) {
    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, text));
    expect(button.onPressed, isNull);
  }

  // Form validation helpers
  static Future<void> testFieldValidation(
    WidgetTester tester, {
    required String fieldKey,
    required String invalidValue,
    required String expectedError,
  }) async {
    await tester.enterText(find.byKey(Key(fieldKey)), invalidValue);
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pump();
    expect(find.text(expectedError), findsOneWidget);
  }

  // API response testing helpers
  static Map<String, dynamic> createSuccessResponse(dynamic data) {
    return {
      'success': true,
      'data': data,
    };
  }

  static Map<String, dynamic> createErrorResponse(String message) {
    return {
      'success': false,
      'error': message,
    };
  }

  // Date testing helpers
  static DateTime createTestDate({
    int year = 2024,
    int month = 12,
    int day = 25,
    int hour = 10,
    int minute = 0,
  }) {
    return DateTime(year, month, day, hour, minute);
  }

  static String formatDateForApi(DateTime date) {
    return date.toIso8601String();
  }

  // Theme testing helpers
  static ThemeData createTestTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }

  // Accessibility testing helpers
  static void checkAccessibilitySemantics(WidgetTester tester, {required String expectedLabel}) {
    expect(find.bySemanticsLabel(expectedLabel), findsOneWidget);
  }

  // Performance testing helpers
  static Future<void> measureRenderTime(
    WidgetTester tester, {
    required Future<void> Function() action,
    int maxDurationMs = 1000,
  }) async {
    final stopwatch = Stopwatch()..start();
    await action();
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(maxDurationMs));
  }

  // Integration testing helpers
  static Future<void> completeUserFlow(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    // Login
    await fillLoginForm(tester, email: email, password: password);
    await submitForm(tester);
    await waitForLoading(tester);

    // Navigate to dashboard
    expect(find.text('Dashboard'), findsOneWidget);
  }

  // Error scenario testing helpers
  static Future<void> simulateNetworkError(WidgetTester tester) async {
    // This would need to be implemented based on your error handling strategy
    await tester.pump(const Duration(seconds: 2));
  }

  static Future<void> simulateServerError(WidgetTester tester) async {
    // This would need to be implemented based on your error handling strategy
    await tester.pump(const Duration(seconds: 2));
  }

  // Data persistence testing helpers
  static void verifyDataPersistence<T>(T expectedData, T actualData) {
    expect(actualData, equals(expectedData));
  }

  // State management testing helpers
  static void verifyProviderState<T>(AsyncValue<T> providerState, T expectedValue) {
    expect(providerState.value, equals(expectedValue));
    expect(providerState.isLoading, false);
    expect(providerState.hasError, false);
  }

  static void verifyProviderLoading<T>(AsyncValue<T> providerState) {
    expect(providerState.isLoading, true);
    expect(providerState.hasError, false);
  }

  static void verifyProviderError<T>(AsyncValue<T> providerState) {
    expect(providerState.hasError, true);
    expect(providerState.isLoading, false);
  }

  // Utility methods
  static void debugPrintWidgetTree(WidgetTester tester) {
    debugPrint('Widget Tree:');
    debugPrint(tester.binding.renderViewElement?.toStringDeep() ?? 'No render element');
  }

  static void debugPrintProviderStates(ProviderContainer container) {
    debugPrint('Provider States:');
    // Add provider state debugging as needed
  }

  static Future<void> pumpWithDuration(WidgetTester tester, Duration duration) async {
    await tester.pump();
    await tester.pump(duration);
  }

  // Clean up helpers
  static void disposeTestResources() {
    // Clean up any test resources
  }
}

// Mock classes for testing
class MockAuthNotifier extends AsyncNotifier<AuthState> {
  final LocalUser _user;

  MockAuthNotifier(this._user);

  @override
  Future<AuthState> build() async {
    return AuthState.authenticated(_user);
  }

  Future<String?> signIn({required String email, required String password}) async {
    if (email == 'error@test.com') return 'Login failed';
    return null;
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    if (email == 'exists@test.com') return 'Email already exists';
    return null;
  }

  Future<void> signOut() async {
    state = const AsyncData(AuthState.unauthenticated());
  }
}

// Test configuration
class TestConfig {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(minutes: 2);

  static const int maxTestRetries = 3;
  static const int maxWidgetRetries = 5;

  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testName = 'Test User';

  static const String invalidEmail = 'invalid-email';
  static const String shortPassword = '123';
  static const String wrongPassword = 'wrongpassword';
}

// Custom matchers for testing
class IsNotEmptyString extends Matcher {
  const IsNotEmptyString();

  @override
  bool matches(covariant String item, Map matchState) => item.isNotEmpty;

  @override
  Description describe(Description description) =>
      description.add('a non-empty string');
}

class IsValidEmail extends Matcher {
  const IsValidEmail();

  @override
  bool matches(covariant String item, Map matchState) {
    return item.contains('@') && item.contains('.');
  }

  @override
  Description describe(Description description) =>
      description.add('a valid email address');
}

// Extension methods for easier testing
extension WidgetTesterX on WidgetTester {
  Future<void> waitForAndPump({Duration? duration}) async {
    await pump(duration ?? const Duration(milliseconds: 100));
    await pumpAndSettle();
  }

  Future<void> tapAndPump(Finder finder, {Duration? duration}) async {
    await tap(finder);
    await waitForAndPump(duration: duration);
  }

  Future<void> enterTextAndPump(Finder finder, String text, {Duration? duration}) async {
    await enterText(finder, text);
    await waitForAndPump(duration: duration);
  }
}

// Global test setup and teardown
void setUpTests() {
  // Initialize test environment
  TestWidgetsFlutterBinding.ensureInitialized();
}

void tearDownTests() {
  // Clean up test environment
  TestHelpers.disposeTestResources();
}

// Custom test utilities
extension StringX on String {
  bool get isValidEmail => this.contains('@') && this.contains('.');
  bool get isNotEmpty => this.trim().isNotEmpty;
  bool get isShortPassword => this.length < 6;
}

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return day == tomorrow.day && month == tomorrow.month && year == tomorrow.year;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());
}
