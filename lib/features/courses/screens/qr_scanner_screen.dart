import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/services/qr_scanner_service.dart';
import '../../../core/services/hive_storage_service.dart';

/// Pantalla para escanear QR y unirse a un curso
/// El QR tiene formato: COURSE_<courseId>_<timestamp>
class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  late MobileScannerController cameraController;
  final QRScannerService _qrScanner = QRScannerService();
  final HiveStorageService _storage = HiveStorageService();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleQRCode(String qrCode) {
    if (_isProcessing) return;

    _isProcessing = true;

    if (_qrScanner.isValidCourseQR(qrCode)) {
      // Guardar en historial
      _storage.saveQRScan(qrCode);

      // Extraer ID del curso
      final courseId = _qrScanner.extractIdFromQR(qrCode);

      _showSuccessDialog(
        title: '✅ Curso Encontrado',
        message: 'Te has unido al curso exitosamente.',
        courseId: courseId,
      );
    } else {
      _showErrorDialog(
        title: '❌ QR Inválido',
        message: 'Este QR no corresponde a un curso válido.',
      );
    }

    _isProcessing = false;
  }

  void _showSuccessDialog({
    required String title,
    required String message,
    String? courseId,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    ).then((_) {
      if (courseId != null) {
        Navigator.pop(context, courseId);
      }
    });
  }

  void _showErrorDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
        centerTitle: true,
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Barcode found: ${barcode.rawValue}');
            if (barcode.rawValue != null) {
              _handleQRCode(barcode.rawValue!);
            }
          }
        },
        overlay: CustomPaint(
          painter: QRScannerOverlayPainter(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => cameraController.toggleTorch(),
        tooltip: 'Flash',
        child: const Icon(Icons.flashlight_on),
      ),
    );
  }
}

/// Painter para dibujar el rectángulo de escaneo
class QRScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Oscurecer las esquinas
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    const qrSize = 300.0;
    final left = (width - qrSize) / 2;
    final top = (height - qrSize) / 2;

    // Dibujar rectángulos oscuros en las esquinas
    canvas.drawRect(Rect.fromLTWH(0, 0, width, top), paint);
    canvas.drawRect(Rect.fromLTWH(0, top + qrSize, width, height - top - qrSize), paint);
    canvas.drawRect(Rect.fromLTWH(0, top, left, qrSize), paint);
    canvas.drawRect(Rect.fromLTWH(left + qrSize, top, width - left - qrSize, qrSize), paint);

    // Dibujar borde del rectángulo
    final borderPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(left, top, qrSize, qrSize),
      borderPaint,
    );

    // Dibujar esquinas
    const cornerSize = 30.0;
    final cornerPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Esquina superior izquierda
    canvas.drawLine(Offset(left, top), Offset(left + cornerSize, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerSize), cornerPaint);

    // Esquina superior derecha
    canvas.drawLine(Offset(left + qrSize, top), Offset(left + qrSize - cornerSize, top), cornerPaint);
    canvas.drawLine(Offset(left + qrSize, top), Offset(left + qrSize, top + cornerSize), cornerPaint);

    // Esquina inferior izquierda
    canvas.drawLine(Offset(left, top + qrSize), Offset(left + cornerSize, top + qrSize), cornerPaint);
    canvas.drawLine(Offset(left, top + qrSize), Offset(left, top + qrSize - cornerSize), cornerPaint);

    // Esquina inferior derecha
    canvas.drawLine(Offset(left + qrSize, top + qrSize), Offset(left + qrSize - cornerSize, top + qrSize), cornerPaint);
    canvas.drawLine(Offset(left + qrSize, top + qrSize), Offset(left + qrSize, top + qrSize - cornerSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
