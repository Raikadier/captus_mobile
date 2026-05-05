import 'package:dio/dio.dart';
import '../env/env.dart';
import 'supabase_service.dart';

/// Dio HTTP client pre-configured to talk to the Captus Express backend.
///
/// Automatically attaches the Supabase JWT on every request so the backend
/// can verify identity via the same token the web app uses.
///
/// Usage:
///   final res = await ApiClient.instance.get('/tasks');
///   final res = await ApiClient.instance.post('/tasks', data: {...});
class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      _LogInterceptor(),
    ]);

    return dio;
  }

  // ── Convenience wrappers ──────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, options: options);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) =>
      _dio.delete<T>(path, options: options);
}

// ── Interceptors ─────────────────────────────────────────────────────────────

/// Attaches the Supabase JWT access token to every outgoing request.
/// If the token is expired, Supabase refreshes it automatically before we read it.
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = SupabaseService.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 → session expired; could trigger a sign-out here
    if (err.response?.statusCode == 401) {
      SupabaseService.auth.signOut();
    }
    handler.next(err);
  }
}

/// Minimal request/response logger for debug builds.
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[API] ${options.method} ${options.path}');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print(
          '[API] ERROR ${err.response?.statusCode} ${err.requestOptions.path}: ${err.message}');
      return true;
    }());
    handler.next(err);
  }
}

/// Typed API error returned by [ApiException.fromDio].
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException({this.statusCode, required this.message});

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    final serverMsg =
        (data is Map ? data['message'] ?? data['error'] : null) as String?;
    return ApiException(
      statusCode: e.response?.statusCode,
      message: serverMsg ?? e.message ?? 'Error de conexión',
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
