# Testing Guide for Captus Mobile

This directory contains all tests for the Captus Mobile Flutter application. The test suite is organized to ensure comprehensive coverage of the application's functionality.

## Test Structure

```
test/
├── models/                    # Unit tests for data models
│   ├── user_model_test.dart
│   ├── local_user_test.dart
│   └── course_model_test.dart
├── providers/                 # Unit tests for Riverpod providers
│   ├── auth_provider_test.dart
│   ├── courses_provider_test.dart
│   └── tasks_provider_test.dart
├── widgets/                   # Widget tests for UI components
│   ├── login_screen_test.dart
│   └── home_dashboard_test.dart
├── integration/               # Integration tests
│   ├── supabase_service_test.dart
│   └── api_client_test.dart
├── helpers/                   # Test utilities and mock data
│   ├── mock_data.dart
│   └── test_helpers.dart
└── widget_test.dart          # Basic smoke tests
```

## Test Types

### 1. Unit Tests
- **Models**: Test data model serialization, validation, and business logic
- **Providers**: Test Riverpod provider state management and business logic
- **Services**: Test individual service methods in isolation

### 2. Widget Tests
- **UI Components**: Test widget rendering, user interactions, and state changes
- **Screens**: Test complete screen workflows and navigation
- **Form Validation**: Test form inputs, validation, and error handling

### 3. Integration Tests
- **API Integration**: Test API client communication and error handling
- **Service Integration**: Test service interactions and data flow
- **End-to-End**: Test complete user workflows

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/models/user_model_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Tests on Specific Platform
```bash
flutter test --platform chrome
flutter test --platform ios
flutter test --platform android
```

### Run Tests with Tags
```bash
flutter test --name="Login Screen"
flutter test --tags="integration"
```

## Test Dependencies

The project uses the following testing dependencies:

- `flutter_test`: Flutter's testing framework
- `mockito`: For creating mock objects
- `build_runner`: For generating mock files
- `golden_toolkit`: For golden tests (visual regression testing)
- `network_image_mock`: For mocking network images in tests
- `integration_test`: For integration testing

## Mock Data

### Using Mock Data
```dart
import 'package:captus_mobile/test/helpers/mock_data.dart';

// Use predefined mock data
final mockUser = MockData.mockStudent;
final mockCourses = MockData.mockCourses;
final mockTasks = MockData.mockTasks;
```

### Creating Custom Mock Data
```dart
// Create custom mock user
final customUser = TestHelpers.createMockUser(
  email: 'custom@example.com',
  role: 'teacher',
);

// Create custom mock course
final customCourse = TestHelpers.createMockCourse(
  name: 'Custom Course',
  progress: 0.8,
);
```

## Test Best Practices

### 1. Test Naming
- Use descriptive test names that explain what is being tested
- Follow the pattern: `should_[expected_behavior]_when_[condition]`

### 2. Test Structure
- **Arrange**: Set up test data and mocks
- **Act**: Perform the action being tested
- **Assert**: Verify the expected outcome

### 3. Mock Objects
- Use mocks to isolate units under test
- Mock external dependencies (APIs, databases, etc.)
- Verify mock interactions when necessary

### 4. Test Coverage
- Aim for high test coverage but focus on critical paths
- Test happy paths, edge cases, and error conditions
- Test both positive and negative scenarios

### 5. Widget Testing
- Use `pumpAndSettle()` for async operations
- Test user interactions (taps, scrolls, text input)
- Verify UI state changes and navigation

## Example Test Structure

### Unit Test Example
```dart
test('should create UserModel from valid JSON', () {
  // Arrange
  final json = {
    'id': '123',
    'name': 'John Doe',
    'email': 'john@example.com',
    'role': 'student',
  };

  // Act
  final userModel = UserModel.fromJson(json);

  // Assert
  expect(userModel.id, '123');
  expect(userModel.name, 'John Doe');
  expect(userModel.email, 'john@example.com');
  expect(userModel.role, UserRole.student);
});
```

### Widget Test Example
```dart
testWidgets('should display login form elements', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(createTestWidget(child: LoginScreen()));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Iniciar sesión'), findsOneWidget);
  expect(find.byType(TextFormField), findsNWidgets(2));
  expect(find.text('Entrar'), findsOneWidget);
});
```

### Integration Test Example
```dart
test('should login successfully with valid credentials', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(createTestWidget(child: LoginScreen()));
  await tester.pumpAndSettle();

  // Act
  await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
  await tester.enterText(find.byKey(Key('password_field')), 'password123');
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Dashboard'), findsOneWidget);
});
```

## Generating Mock Files

When using mockito, you need to generate mock files:

```bash
flutter packages pub run build_runner build
```

For continuous development:
```bash
flutter packages pub run build_runner watch
```

To rebuild mocks:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Test Configuration

### Test Timeout
Default test timeout is 30 seconds. You can configure this in individual tests:

```dart
testWidgets('long running test', (WidgetTester tester) async {
  // Test code
}, timeout: const Timeout(Duration(minutes: 2)));
```

### Test Environment
Tests run in a controlled environment without network access or real services. Use mocks to simulate external dependencies.

## Continuous Integration

### GitHub Actions Example
```yaml
- name: Run Tests
  run: |
    flutter test --coverage
    flutter pub global activate coverage
    flutter pub global run coverage:format_coverage --lcov --in coverage/lcov.info --out coverage/lcov.info
    bash <(curl -s https://codecov.io/bash)
```

## Debugging Tests

### Print Debug Information
```dart
testWidgets('debug test', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  await tester.pumpAndSettle();
  
  // Print widget tree
  debugPrint(tester.binding.renderViewElement?.toStringDeep());
});
```

### Breakpoints in Tests
Use IDE breakpoints in test files to debug test execution.

## Performance Testing

Use `benchmark` tests for performance-critical code:

```dart
testWidgets('performance test', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  
  await tester.binding.delayed(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  
  // Measure performance
  final stopwatch = Stopwatch()..start();
  // Perform action
  stopwatch.stop();
  
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
});
```

## Golden Tests

For visual regression testing:

```dart
testWidgets('golden test', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  await expectLater(
    find.byType(MyWidget),
    matchesGoldenFile('goldens/my_widget.png'),
  );
});
```

## Troubleshooting

### Common Issues

1. **Tests failing due to network requests**: Use mocks to simulate API responses
2. **Async operations not completing**: Use `pumpAndSettle()` appropriately
3. **Widget not found**: Check if widget is actually rendered and visible
4. **Mock generation failing**: Run `flutter pub get` and regenerate mocks

### Test Flakiness

If tests are flaky:
1. Add proper waits for async operations
2. Use `pumpAndSettle()` instead of `pump()`
3. Add explicit delays if necessary
4. Check for race conditions in test setup

## Contributing

When adding new tests:

1. Follow the established naming conventions
2. Use the helper utilities in `test/helpers/`
3. Add appropriate mock data if needed
4. Ensure tests are isolated and don't depend on each other
5. Update this README if adding new test categories

## Coverage Reports

Generate coverage reports to track test coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Open `coverage/html/index.html` to view the detailed coverage report.
