import 'package:flutter/material.dart';

/// Servicio para escanear códigos QR
/// Se usa para:
/// - Registrarse a cursos mediante QR
/// - Unirse a grupos
/// - Verificar asistencia
class QRScannerService {
  static final QRScannerService _instance = QRScannerService._internal();

  QRScannerService._internal();

  factory QRScannerService() {
    return _instance;
  }

  /// Valida si un string es un QR de curso válido
  /// Formato: COURSE_<courseId>_<timestamp>
  bool isValidCourseQR(String qrCode) {
    try {
      return qrCode.startsWith('COURSE_') && 
             qrCode.split('_').length >= 3;
    } catch (e) {
      debugPrint('Error validating course QR: $e');
      return false;
    }
  }

  /// Valida si un string es un QR de grupo válido
  /// Formato: GROUP_<groupId>_<timestamp>
  bool isValidGroupQR(String qrCode) {
    try {
      return qrCode.startsWith('GROUP_') && 
             qrCode.split('_').length >= 3;
    } catch (e) {
      debugPrint('Error validating group QR: $e');
      return false;
    }
  }

  /// Valida si un string es un QR de asistencia válido
  /// Formato: ATTENDANCE_<courseId>_<timestamp>
  bool isValidAttendanceQR(String qrCode) {
    try {
      return qrCode.startsWith('ATTENDANCE_') && 
             qrCode.split('_').length >= 3;
    } catch (e) {
      debugPrint('Error validating attendance QR: $e');
      return false;
    }
  }

  /// Extrae el ID del QR
  String? extractIdFromQR(String qrCode) {
    try {
      final parts = qrCode.split('_');
      if (parts.length >= 2) {
        return parts[1];
      }
    } catch (e) {
      debugPrint('Error extracting ID from QR: $e');
    }
    return null;
  }

  /// Extrae el tipo de QR
  String? extractTypeFromQR(String qrCode) {
    try {
      return qrCode.split('_').first;
    } catch (e) {
      debugPrint('Error extracting type from QR: $e');
    }
    return null;
  }

  /// Valida la antigüedad del QR (máximo 24 horas)
  bool isQRExpired(String qrCode) {
    try {
      final parts = qrCode.split('_');
      if (parts.length < 3) return true;
      
      final timestamp = int.tryParse(parts[2]);
      if (timestamp == null) return true;
      
      final qrTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(qrTime);
      
      // QR válido por 24 horas
      return difference.inHours > 24;
    } catch (e) {
      debugPrint('Error checking QR expiration: $e');
      return true;
    }
  }
}
