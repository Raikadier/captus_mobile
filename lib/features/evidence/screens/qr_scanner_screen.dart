import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _detected = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_detected) return;

              final value = capture.barcodes.first.rawValue;

              if (value == null) return;

              _detected = true;
              Navigator.pop(context, value);
            },
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(AppRadius.r9),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Text(
              'Alinea el código dentro del recuadro',
              textAlign: TextAlign.center,
              style: tt.bodyMedium!.copyWith(color: AppColors.textOnPrimary),
            ),
          )
        ],
      ),
    );
  }
}