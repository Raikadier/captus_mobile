import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

/// Servicio para generar códigos QR desde datos de la app
/// Se usa para:
/// - Compartir cursos
/// - Compartir grupos
/// - Generar tickets de asistencia
class QRGeneratorService {
  static final QRGeneratorService _instance = QRGeneratorService._internal();

  QRGeneratorService._internal();

  factory QRGeneratorService() {
    return _instance;
  }

  /// Genera un QR para un curso
  /// Formato: COURSE_<courseId>_<timestamp>
  String generateCourseQR(String courseId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'COURSE_${courseId}_$timestamp';
  }

  /// Genera un QR para un grupo
  /// Formato: GROUP_<groupId>_<timestamp>
  String generateGroupQR(String groupId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'GROUP_${groupId}_$timestamp';
  }

  /// Genera un QR para registrar asistencia
  /// Formato: ATTENDANCE_<courseId>_<timestamp>
  String generateAttendanceQR(String courseId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ATTENDANCE_${courseId}_$timestamp';
  }

  /// Genera un QR para compartir tareas
  /// Formato: TASK_<taskId>_<timestamp>
  String generateTaskQR(String taskId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TASK_${taskId}_$timestamp';
  }

  /// Genera datos de imagen PNG a partir de un código QR
  /// Útil para guardar o compartir como archivo
  Future<Uint8List?> generateQRImage(String data) async {
    try {
      final qrCode = QrCode(
        typeNumber: null,
        errorCorrectLevel: QrErrorCorrectLevel.H,
      );
      qrCode.addData(data);
      qrCode.make();
      
      return null; // Placeholder - la generación de imagen se hace en widgets
    } catch (e) {
      debugPrint('Error generating QR image: $e');
      return null;
    }
  }
}
