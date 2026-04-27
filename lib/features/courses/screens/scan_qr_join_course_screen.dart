import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';

class ScanQRJoinCourseScreen extends StatefulWidget {
  const ScanQRJoinCourseScreen({super.key});

  @override
  State<ScanQRJoinCourseScreen> createState() => _ScanQRJoinCourseScreenState();
}

class _ScanQRJoinCourseScreenState extends State<ScanQRJoinCourseScreen> {
  static const _scanFrameSize = 248.0;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessingScan = false;
  bool _isFeedbackActive = false;
  DateTime? _lastInvalidFeedbackAt;
  String? _pendingInviteCode;
  DateTime? _pendingInviteAt;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessingScan) return;

    final rawValue =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    final inviteCode = _extractInviteCode(rawValue);
    if (inviteCode == null) {
      _pendingInviteCode = null;
      _pendingInviteAt = null;
      final now = DateTime.now();
      if (_lastInvalidFeedbackAt == null ||
          now.difference(_lastInvalidFeedbackAt!) >
              const Duration(milliseconds: 1200)) {
        _lastInvalidFeedbackAt = now;
        _showInvalidQR();
      }
      return;
    }

    final now = DateTime.now();
    final isSameAsPrevious = _pendingInviteCode == inviteCode &&
        _pendingInviteAt != null &&
        now.difference(_pendingInviteAt!) <= const Duration(seconds: 2) &&
        now.difference(_pendingInviteAt!) >= const Duration(milliseconds: 350);

    if (!isSameAsPrevious) {
      setState(() {
        _pendingInviteCode = inviteCode;
        _pendingInviteAt = now;
      });
      return;
    }

    setState(() {
      _isProcessingScan = true;
      _isFeedbackActive = true;
      _pendingInviteCode = null;
      _pendingInviteAt = null;
    });

    HapticFeedback.mediumImpact();
    await _controller.stop();
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    context.push('/join?code=${Uri.encodeQueryComponent(inviteCode)}');
  }

  String? _extractInviteCode(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;

    final code = uri.queryParameters['code']?.trim();
    if (code == null || code.isEmpty) return null;

    final path = uri.path.toLowerCase().replaceAll(RegExp(r'/+$'), '');
    final host = uri.host.toLowerCase();
    final scheme = uri.scheme.toLowerCase();

    final isCaptusScheme = scheme == 'captus' && host == 'join';
    final isCaptusWeb = (scheme == 'https' || scheme == 'http') &&
        host == 'captus.app' &&
        path == '/join';

    if (!isCaptusScheme && !isCaptusWeb) return null;
    return code.toUpperCase();
  }

  void _showInvalidQR() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('QR no válido'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final hasPendingConfirmation = _pendingInviteCode != null && !_isProcessingScan;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Escanear QR',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return _PermissionErrorView(
                onRetry: () => _controller.start(),
              );
            },
          ),
          _ScannerOverlay(
            frameSize: _scanFrameSize,
            isDetected: _isFeedbackActive,
          ),
          Align(
            alignment: const Alignment(0, 0.62),
            child: Text(
              _isProcessingScan
                  ? 'QR detectado, conectando...'
                  : hasPendingConfirmation
                      ? 'Mantener enfoque para confirmar QR'
                      : 'Escanea el QR del curso',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PermissionErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt_outlined,
              color: AppColors.textSecondary, size: 44),
          const SizedBox(height: 14),
          Text(
            'Necesitamos acceso a la cámara',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activa el permiso de cámara para escanear el QR del curso.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  final double frameSize;
  final bool isDetected;

  const _ScannerOverlay({
    required this.frameSize,
    required this.isDetected,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.55),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: frameSize,
                    height: frameSize,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: frameSize,
              height: frameSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDetected ? Colors.greenAccent : AppColors.primary,
                  width: isDetected ? 3 : 2,
                ),
                boxShadow: [
                  if (isDetected)
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.45),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
