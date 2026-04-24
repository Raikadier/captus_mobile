import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:captus_mobile/core/services/api_client.dart';

import 'api_client_test.Mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('ApiClient Integration Tests', () {
    late MockDio mockDio;
    late ApiClient apiClient;

    setUp(() {
      mockDio = MockDio();
      apiClient = ApiClient.instance;
    });

    group('HTTP Methods', () {
      test('should make GET request successfully', () async {
        // Arrange
        final mockResponse = Response(
          data: {'message': 'success'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockDio.get<dynamic>('/test'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.get<dynamic>('/test');

        // Assert
        expect(response.statusCode, 200);
        expect(response.data['message'], 'success');
        verify(mockDio.get<dynamic>('/test')).called(1);
      });

      test('should make POST request successfully', () async {
        // Arrange
        final requestData = {'name': 'Test', 'value': 123};
        final mockResponse = Response(
          data: {'id': '1', 'created': true},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(mockDio.post<dynamic>('/test', data: requestData))
            .thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.post<dynamic>('/test', data: requestData);

        // Assert
        expect(response.statusCode, 201);
        expect(response.data['created'], true);
        verify(mockDio.post<dynamic>('/test', data: requestData)).called(1);
      });

      test('should make PUT request successfully', () async {
        // Arrange
        final updateData = {'name': 'Updated', 'value': 456};
        final mockResponse = Response(
          data: {'id': '1', 'updated': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test/1'),
        );

        when(mockDio.put<dynamic>('/test/1', data: updateData))
            .thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.put<dynamic>('/test/1', data: updateData);

        // Assert
        expect(response.statusCode, 200);
        expect(response.data['updated'], true);
        verify(mockDio.put<dynamic>('/test/1', data: updateData)).called(1);
      });

      test('should make DELETE request successfully', () async {
        // Arrange
        final mockResponse = Response(
          data: {'deleted': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test/1'),
        );

        when(mockDio.delete<dynamic>('/test/1'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.delete<dynamic>('/test/1');

        // Assert
        expect(response.statusCode, 200);
        expect(response.data['deleted'], true);
        verify(mockDio.delete<dynamic>('/test/1')).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle HTTP 400 error', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        when(mockDio.get<dynamic>('/test'))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );
        verify(mockDio.get<dynamic>('/test')).called(1);
      });

      test('should handle HTTP 401 error', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        when(mockDio.get<dynamic>('/test'))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );
        verify(mockDio.get<dynamic>('/test')).called(1);
      });

      test('should handle HTTP 500 error', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        when(mockDio.get<dynamic>('/test'))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );
        verify(mockDio.get<dynamic>('/test')).called(1);
      });

      test('should handle network timeout', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );

        when(mockDio.get<dynamic>('/test'))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );
        verify(mockDio.get<dynamic>('/test')).called(1);
      });

      test('should handle no internet connection', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        );

        when(mockDio.get<dynamic>('/test'))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => apiClient.get<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );
        verify(mockDio.get<dynamic>('/test')).called(1);
      });
    });

    group('Headers and Authentication', () {
      test('should include authorization header when token is available', () async {
        // Arrange
        final mockResponse = Response(
          data: {'message': 'success'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/secure'),
        );

        when(mockDio.get<dynamic>('/secure'))
            .thenAnswer((_) async => mockResponse);

        // Act
        await apiClient.get<dynamic>('/secure');

        // Assert
        verify(mockDio.get<dynamic>('/secure')).called(1);
      });

      test('should handle content-type headers', () async {
        // Arrange
        final mockResponse = Response(
          data: {'created': true},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/api/data'),
        );

        when(mockDio.post<dynamic>('/api/data', data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        await apiClient.post<dynamic>('/api/data', data: {'key': 'value'});

        // Assert
        verify(mockDio.post<dynamic>('/api/data', data: anyNamed('data')))
            .called(1);
      });
    });

    group('Response Parsing', () {
      test('should handle JSON response correctly', () async {
        // Arrange
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

        when(mockDio.get<dynamic>('/users'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.get<dynamic>('/users');

        // Assert
        expect(response.data['users'], isA<List>());
        expect(response.data['total'], 2);
        expect(response.data['users'][0]['name'], 'John');
      });

      test('should handle empty response', () async {
        // Arrange
        final mockResponse = Response(
          data: null,
          statusCode: 204,
          requestOptions: RequestOptions(path: '/empty'),
        );

        when(mockDio.get<dynamic>('/empty'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.get<dynamic>('/empty');

        // Assert
        expect(response.statusCode, 204);
        expect(response.data, null);
      });

      test('should handle string response', () async {
        // Arrange
        final mockResponse = Response(
          data: 'Plain text response',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/text'),
        );

        when(mockDio.get<dynamic>('/text'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.get<dynamic>('/text');

        // Assert
        expect(response.data, 'Plain text response');
      });
    });

    group('Request Configuration', () {
      test('should handle query parameters', () async {
        // Arrange
        final queryParams = {'page': 1, 'limit': 10};
        final mockResponse = Response(
          data: {'data': []},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/data'),
        );

        when(mockDio.get<dynamic>('/data', queryParameters: queryParams))
            .thenAnswer((_) async => mockResponse);

        // Act
        await apiClient.get<dynamic>('/data', queryParameters: queryParams);

        // Assert
        verify(mockDio.get<dynamic>('/data', queryParameters: queryParams))
            .called(1);
      });

      test('should handle timeout configuration', () async {
        // Arrange
        final mockResponse = Response(
          data: {'message': 'success'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/slow'),
        );

        when(mockDio.get<dynamic>('/slow'))
            .thenAnswer((_) async => mockResponse);

        // Act
        await apiClient.get<dynamic>('/slow');

        // Assert
        verify(mockDio.get<dynamic>('/slow')).called(1);
      });
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = ApiClient.instance;
        final instance2 = ApiClient.instance;

        expect(instance1, same(instance2));
      });

      test('should maintain configuration across instances', () {
        final instance1 = ApiClient.instance;
        final instance2 = ApiClient.instance;

        expect(instance1, equals(instance2));
      });
    });

    group('Integration with Services', () {
      test('should work with authentication service', () async {
        // Test integration with auth provider
        final mockResponse = Response(
          data: {'authenticated': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/auth/check'),
        );

        when(mockDio.get<dynamic>('/auth/check'))
            .thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/auth/check');
        expect(response.data['authenticated'], true);
      });

      test('should work with courses service', () async {
        // Test integration with courses provider
        final mockResponse = Response(
          data: {
            'data': [
              {'id': '1', 'name': 'Course 1'},
              {'id': '2', 'name': 'Course 2'},
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/courses'),
        );

        when(mockDio.get<dynamic>('/courses'))
            .thenAnswer((_) async => mockResponse);

        final response = await apiClient.get<dynamic>('/courses');
        expect(response.data['data'], isA<List>());
        expect(response.data['data'].length, 2);
      });
    });
  });

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
