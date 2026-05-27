import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:captus_mobile/core/utils/app_errors.dart';

/// Creates a fresh RequestOptions for each test call.
RequestOptions _opts() => RequestOptions(path: '/test');

void main() {
  group('friendlyError — Dio exceptions', () {
    test('returns timeout message on connectionTimeout', () {
      final e = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: _opts(),
      );
      final msg = friendlyError(e);
      expect(msg, contains('tardó demasiado'));
    });

    test('returns timeout message on receiveTimeout', () {
      final e = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: _opts(),
      );
      expect(friendlyError(e), contains('tardó demasiado'));
    });

    test('returns timeout message on sendTimeout', () {
      final e = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: _opts(),
      );
      expect(friendlyError(e), contains('tardó demasiado'));
    });

    test('returns cancelled message on cancel', () {
      final e = DioException(
        type: DioExceptionType.cancel,
        requestOptions: _opts(),
      );
      expect(friendlyError(e), contains('cancelada'));
    });

    test('returns no-connection message on connectionError', () {
      final e = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: _opts(),
      );
      expect(friendlyError(e), contains('Sin conexión'));
    });

    test('returns 400 message for bad request', () {
      final opts = _opts();
      final e = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 400, requestOptions: opts),
        requestOptions: opts,
      );
      expect(friendlyError(e), contains('válidos'));
    });

    test('returns 401 message for unauthorized', () {
      final opts = _opts();
      final e = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 401, requestOptions: opts),
        requestOptions: opts,
      );
      expect(friendlyError(e), contains('sesión expiró'));
    });

    test('returns 403 message for forbidden', () {
      final opts = _opts();
      final e = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 403, requestOptions: opts),
        requestOptions: opts,
      );
      expect(friendlyError(e), contains('permiso'));
    });

    test('returns 404 message for not found', () {
      final opts = _opts();
      final e = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 404, requestOptions: opts),
        requestOptions: opts,
      );
      expect(friendlyError(e), contains('encontró'));
    });

    test('returns 409 message for conflict', () {
      final opts = _opts();
      final e = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 409, requestOptions: opts),
        requestOptions: opts,
      );
      expect(friendlyError(e), contains('ya existe'));
    });

    test('returns 429 message for rate limit', () {
      final opts = _opts();
      final e = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 429, requestOptions: opts),
        requestOptions: opts,
      );
      expect(friendlyError(e), contains('Demasiadas'));
    });

    test('returns 500 message for server error', () {
      final opts = _opts();
      final e = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 500, requestOptions: opts),
        requestOptions: opts,
      );
      expect(friendlyError(e), contains('servidor'));
    });

    test('returns 503 message for service unavailable', () {
      final opts = _opts();
      final e = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 503, requestOptions: opts),
        requestOptions: opts,
      );
      expect(friendlyError(e), contains('servidor'));
    });

    test('returns generic network message for unknown Dio type', () {
      final e = DioException(
        type: DioExceptionType.unknown,
        requestOptions: _opts(),
      );
      expect(friendlyError(e), contains('red'));
    });
  });

  group('friendlyError — generic exceptions', () {
    test('detects not-authenticated in message', () {
      final msg = friendlyError(Exception('not authenticated'));
      expect(msg, contains('sesión'));
    });

    test('detects unauthorized keyword', () {
      expect(friendlyError(Exception('unauthorized')), contains('sesión'));
    });

    test('detects invalid login', () {
      expect(friendlyError(Exception('invalid login')), contains('contraseña'));
    });

    test('detects SocketException / network', () {
      expect(friendlyError(Exception('SocketException')), contains('conexión'));
    });

    test('detects failed host lookup', () {
      expect(friendlyError(Exception('failed host lookup')), contains('internet'));
    });

    test('detects timeout string', () {
      expect(friendlyError(Exception('timeout')), contains('tardó'));
    });

    test('detects 500 string', () {
      expect(friendlyError(Exception('500')), contains('servidor'));
    });

    test('detects 404 string', () {
      expect(friendlyError(Exception('404')), contains('encontró'));
    });

    test('detects 403 string', () {
      expect(friendlyError(Exception('403')), contains('permiso'));
    });

    test('detects storage keyword', () {
      expect(friendlyError(Exception('storage error')), contains('archivo'));
    });

    test('detects file keyword', () {
      expect(friendlyError(Exception('file upload failed')), contains('archivo'));
    });

    test('uses fallback for unrecognised exception', () {
      const custom = 'Operación fallida';
      final msg = friendlyError(Exception('xyz_unknown_xyz'), fallback: custom);
      expect(msg, custom);
    });

    test('default fallback message is set', () {
      final msg = friendlyError(Exception('completely unknown error xyz_abc'));
      expect(msg, 'Algo salió mal. Intenta de nuevo.');
    });
  });
}
