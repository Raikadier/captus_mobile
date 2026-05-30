import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:captus_mobile/core/services/api_client.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('ApiClient Integration Tests', () {
    late MockDio mockDio;
    late ApiClient apiClient;

    setUp(() {
      // Initialise dotenv so ApiClient can read Env.apiBaseUrl without crashing.
      dotenv.testLoad(mergeWith: {
        'API_BASE_URL': 'http://localhost:3000/api',
        'SUPABASE_URL': 'https://test.supabase.co',
        'SUPABASE_ANON_KEY': 'test-anon-key',
      });

      mockDio = MockDio();

      // KEY FIX: use ApiClient.forTesting() so the MockDio is the one
      // that executes requests — NOT the real singleton's internal Dio.
      apiClient = ApiClient.forTesting(mockDio);
    });

    // ── HTTP Methods ─────────────────────────────────────────────────────────

    group('HTTP Methods', () {
      test('should make GET request successfully', () async {
        final mockResponse = Response(
          data: {'message': 'success'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockDio.get<dynamic>(
          '/test',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/test');

        expect(response.statusCode, 200);
        expect(response.data['message'], 'success');
        verify(mockDio.get<dynamic>(
          '/test',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('should make POST request successfully', () async {
        final requestData = {'name': 'Test', 'value': 123};
        final mockResponse = Response(
          data: {'id': '1', 'created': true},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockDio.post<dynamic>(
          '/test',
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.post<dynamic>('/test', data: requestData);

        expect(response.statusCode, 201);
        expect(response.data['created'], true);
        verify(mockDio.post<dynamic>(
          '/test',
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        )).called(1);
      });

      test('should make PUT request successfully', () async {
        final updateData = {'name': 'Updated', 'value': 456};
        final mockResponse = Response(
          data: {'id': '1', 'updated': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test/1'),
        );

        when(mockDio.put<dynamic>(
          '/test/1',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.put<dynamic>('/test/1', data: updateData);

        expect(response.statusCode, 200);
        expect(response.data['updated'], true);
        verify(mockDio.put<dynamic>(
          '/test/1',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('should make DELETE request successfully', () async {
        final mockResponse = Response(
          data: {'deleted': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test/1'),
        );

        when(mockDio.delete<dynamic>(
          '/test/1',
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.delete<dynamic>('/test/1');

        expect(response.statusCode, 200);
        expect(response.data['deleted'], true);
        verify(mockDio.delete<dynamic>(
          '/test/1',
          options: anyNamed('options'),
        )).called(1);
      });
    });

    // ── Error Handling ───────────────────────────────────────────────────────

    group('Error Handling', () {
      test('should handle HTTP 400 error', () async {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        when(mockDio.get<dynamic>(
          '/test',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(dioError);

        await expectLater(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle HTTP 401 error', () async {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        when(mockDio.get<dynamic>(
          '/test',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(dioError);

        await expectLater(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle HTTP 500 error', () async {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        when(mockDio.get<dynamic>(
          '/test',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(dioError);

        await expectLater(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle network timeout', () async {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );

        when(mockDio.get<dynamic>(
          '/test',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(dioError);

        await expectLater(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionTimeout,
          )),
        );
      });

      test('should handle no internet connection', () async {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        );

        when(mockDio.get<dynamic>(
          '/test',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(dioError);

        await expectLater(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionError,
          )),
        );
      });
    });

    // ── Headers and Authentication ───────────────────────────────────────────

    group('Headers and Authentication', () {
      test('should delegate GET to underlying Dio instance', () async {
        final mockResponse = Response(
          data: {'message': 'success'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/secure'),
        );

        when(mockDio.get<dynamic>(
          '/secure',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/secure');

        expect(response.statusCode, 200);
        verify(mockDio.get<dynamic>(
          '/secure',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('should delegate POST with data to underlying Dio instance', () async {
        final mockResponse = Response(
          data: {'created': true},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/api/data'),
        );

        when(mockDio.post<dynamic>(
          '/api/data',
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.post<dynamic>(
          '/api/data',
          data: {'key': 'value'},
        );

        expect(response.data['created'], true);
        verify(mockDio.post<dynamic>(
          '/api/data',
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        )).called(1);
      });
    });

    // ── Response Parsing ─────────────────────────────────────────────────────

    group('Response Parsing', () {
      test('should handle JSON response correctly', () async {
        final jsonData = {
          'users': [
            {'id': 1, 'name': 'John'},
            {'id': 2, 'name': 'Jane'},
          ],
          'total': 2,
        };

        final mockResponse = Response(
          data: jsonData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users'),
        );

        when(mockDio.get<dynamic>(
          '/users',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/users');

        expect(response.data['users'], isA<List>());
        expect(response.data['total'], 2);
        expect(response.data['users'][0]['name'], 'John');
      });

      test('should handle empty response (204)', () async {
        final mockResponse = Response(
          data: null,
          statusCode: 204,
          requestOptions: RequestOptions(path: '/empty'),
        );

        when(mockDio.get<dynamic>(
          '/empty',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/empty');

        expect(response.statusCode, 204);
        expect(response.data, isNull);
      });

      test('should handle plain text response', () async {
        final mockResponse = Response(
          data: 'Plain text response',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/text'),
        );

        when(mockDio.get<dynamic>(
          '/text',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/text');

        expect(response.data, 'Plain text response');
      });
    });

    // ── Request Configuration ────────────────────────────────────────────────

    group('Request Configuration', () {
      test('should pass query parameters to Dio', () async {
        final queryParams = {'page': 1, 'limit': 10};
        final mockResponse = Response(
          data: {'data': []},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/data'),
        );

        when(mockDio.get<dynamic>(
          '/data',
          queryParameters: queryParams,
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        await apiClient.get<dynamic>('/data', queryParameters: queryParams);

        verify(mockDio.get<dynamic>(
          '/data',
          queryParameters: queryParams,
          options: anyNamed('options'),
        )).called(1);
      });

      test('should delegate slow endpoint call to Dio', () async {
        final mockResponse = Response(
          data: {'message': 'success'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/slow'),
        );

        when(mockDio.get<dynamic>(
          '/slow',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/slow');

        expect(response.statusCode, 200);
        verify(mockDio.get<dynamic>(
          '/slow',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });
    });

    // ── Singleton Pattern ────────────────────────────────────────────────────

    group('Singleton Pattern', () {
      test('ApiClient.instance returns the same object every time', () {
        final instance1 = ApiClient.instance;
        final instance2 = ApiClient.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      test('ApiClient.forTesting creates an independent instance', () {
        final testInstance1 = ApiClient.forTesting(MockDio());
        final testInstance2 = ApiClient.forTesting(MockDio());
        // Each forTesting call creates a new object
        expect(identical(testInstance1, testInstance2), isFalse);
        // And neither is the global singleton
        expect(identical(testInstance1, ApiClient.instance), isFalse);
      });
    });

    // ── Integration with Services ────────────────────────────────────────────

    group('Integration with Services', () {
      test('should work with authentication endpoint', () async {
        final mockResponse = Response(
          data: {'authenticated': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/auth/check'),
        );

        when(mockDio.get<dynamic>(
          '/auth/check',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/auth/check');

        expect(response.data['authenticated'], true);
        verify(mockDio.get<dynamic>(
          '/auth/check',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('should work with courses list endpoint', () async {
        final mockResponse = Response(
          data: {
            'data': [
              {'id': '1', 'title': 'Estructuras de Datos'},
              {'id': '2', 'title': 'Cálculo II'},
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/courses/student'),
        );

        when(mockDio.get<dynamic>(
          '/courses/student',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/courses/student');

        expect(response.data['data'], isA<List>());
        expect(response.data['data'].length, 2);
        expect(response.data['data'][0]['title'], 'Estructuras de Datos');
      });
    });

    // ── ApiException ─────────────────────────────────────────────────────────

    group('ApiException', () {
      test('fromDio extracts server message from response body', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 422,
            data: {'message': 'Correo ya registrado'},
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        final ex = ApiException.fromDio(dioError);

        expect(ex.statusCode, 422);
        expect(ex.message, 'Correo ya registrado');
      });

      test('fromDio uses "error" key when "message" is absent', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'error': 'Invalid input'},
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        final ex = ApiException.fromDio(dioError);

        expect(ex.statusCode, 400);
        expect(ex.message, 'Invalid input');
      });

      test('fromDio falls back to "Error de conexión" when no data', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        );

        final ex = ApiException.fromDio(dioError);

        expect(ex.statusCode, isNull);
        expect(ex.message, 'Error de conexión');
      });

      test('toString includes status code and message', () {
        const ex = ApiException(statusCode: 404, message: 'No encontrado');
        expect(ex.toString(), contains('404'));
        expect(ex.toString(), contains('No encontrado'));
      });
    });
  });

  // ── Dio Mock sanity checks ───────────────────────────────────────────────────

  group('Dio Mock Tests', () {
    test('should mock Dio methods correctly', () {
      final mockDio = MockDio();
      expect(mockDio, isA<Dio>());
    });

    test('should mock DioException types', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.unknown,
      );

      expect(dioError, isA<DioException>());
      expect(dioError.type, DioExceptionType.unknown);
    });
  });
}
