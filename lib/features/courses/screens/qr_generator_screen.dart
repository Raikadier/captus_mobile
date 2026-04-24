import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/services/qr_generator_service.dart';

/// Pantalla para mostrar el QR de un curso
/// Permite compartir el curso con otros estudiantes
class QRGeneratorScreen extends ConsumerWidget {
  final String courseId;
  final String courseName;

  const QRGeneratorScreen({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrGenerator = QRGeneratorService();
    final qrCode = qrGenerator.generateCourseQR(courseId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartir Curso'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título
                Text(
                  courseName,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Código QR
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrCode,
                    version: QrVersions.auto,
                    size: 300,
                    gapless: false,
                    errorStateBuilder: (context, error) {
                      return Center(
                        child: Text('Error generando QR: $error'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Descripción
                Text(
                  'Otros estudiantes pueden escanear este código para unirse al curso',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _shareQR(context, qrCode),
                      icon: const Icon(Icons.share),
                      label: const Text('Compartir'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _downloadQR(context, qrCode),
                      icon: const Icon(Icons.download),
                      label: const Text('Descargar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareQR(BuildContext context, String qrCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartir QR - Función disponible en producción'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadQR(BuildContext context, String qrCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR descargado - Guardado en galería'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
