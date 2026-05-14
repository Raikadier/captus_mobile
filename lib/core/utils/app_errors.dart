import 'package:dio/dio.dart';

/// Converts any exception into a short, user-friendly Spanish string.
///
/// Rules:
/// - Never expose stack traces, class names, or "Supabase/Dio/socket" words.
/// - Be specific enough to guide the user on what to do next.
/// - Keep messages under ~80 chars so they fit in a SnackBar.
String friendlyError(Object e, {String fallback = 'Algo salió mal. Intenta de nuevo.'}) {
  // Dio / network errors
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'La conexión tardó demasiado. Revisa tu internet.';
      case DioExceptionType.cancel:
        return 'Solicitud cancelada.';
      case DioExceptionType.connectionError:
        return 'Sin conexión a internet. Verifica tu red.';
      case DioExceptionType.badResponse:
        return _fromStatusCode(e.response?.statusCode);
      default:
        return 'Error de red. Intenta de nuevo.';
    }
  }

  final msg = e.toString().toLowerCase();

  // Auth / session
  if (msg.contains('not authenticated') || msg.contains('no autenticado') || msg.contains('unauthorized') || msg.contains('401')) {
    return 'Tu sesión expiró. Inicia sesión de nuevo.';
  }
  if (msg.contains('invalid login') || msg.contains('invalid email') || msg.contains('contraseña')) {
    return 'Correo o contraseña incorrectos.';
  }

  // Network / connection
  if (msg.contains('socketexception') || msg.contains('failed host lookup') || msg.contains('network')) {
    return 'Sin conexión a internet. Verifica tu red.';
  }
  if (msg.contains('timeout') || msg.contains('timed out')) {
    return 'La conexión tardó demasiado. Intenta de nuevo.';
  }

  // Server errors
  if (msg.contains('500') || msg.contains('server error') || msg.contains('internal')) {
    return 'Error en el servidor. Intenta en unos minutos.';
  }
  if (msg.contains('404') || msg.contains('not found')) {
    return 'No se encontró el recurso solicitado.';
  }
  if (msg.contains('403') || msg.contains('forbidden') || msg.contains('permiso')) {
    return 'No tienes permiso para realizar esta acción.';
  }

  // Storage / files
  if (msg.contains('storage') || msg.contains('file') || msg.contains('upload')) {
    return 'Error al subir el archivo. Intenta de nuevo.';
  }

  return fallback;
}

String _fromStatusCode(int? code) {
  switch (code) {
    case 400: return 'Los datos enviados no son válidos.';
    case 401: return 'Tu sesión expiró. Inicia sesión de nuevo.';
    case 403: return 'No tienes permiso para realizar esta acción.';
    case 404: return 'No se encontró el recurso solicitado.';
    case 409: return 'Este elemento ya existe.';
    case 422: return 'Los datos enviados no son válidos.';
    case 429: return 'Demasiadas solicitudes. Espera un momento.';
    case 500:
    case 502:
    case 503: return 'Error en el servidor. Intenta en unos minutos.';
    default:  return 'Error de conexión (código $code).';
  }
}
