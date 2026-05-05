import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../models/evidence_item.dart';
import '../services/evidence_local_service.dart';
import 'qr_scanner_screen.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final _service = EvidenceLocalService();
  final _picker = ImagePicker();

  List<EvidenceItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _items = _service.getAll();
    });
  }

  Future<void> _capturePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    final evidence = EvidenceItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Foto de evidencia',
      type: 'photo',
      imagePath: photo.path,
      createdAt: DateTime.now(),
    );

    await _service.save(evidence);
    _load();
  }

  Future<void> _saveLocation() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    final evidence = EvidenceItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Ubicación registrada',
      type: 'location',
      latitude: position.latitude,
      longitude: position.longitude,
      createdAt: DateTime.now(),
    );

    await _service.save(evidence);
    _load();
  }

  Future<void> _scanQr() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(),
      ),
    );

    if (result == null) return;

    final evidence = EvidenceItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'QR escaneado',
      type: 'qr_scan',
      qrData: result,
      createdAt: DateTime.now(),
    );

    await _service.save(evidence);
    _load();
  }

  Future<void> _generateQr() async {
    final data = 'CAPTUS-TAREA-${DateTime.now().millisecondsSinceEpoch}';

    final evidence = EvidenceItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'QR generado',
      type: 'qr_generate',
      qrData: data,
      createdAt: DateTime.now(),
    );

    await _service.save(evidence);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Evidencias'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ActionCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Tomar foto',
                  onTap: _capturePhoto,
                ),
                _ActionCard(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'Escanear QR',
                  onTap: _scanQr,
                ),
                _ActionCard(
                  icon: Icons.qr_code_2_rounded,
                  title: 'Generar QR',
                  onTap: _generateQr,
                ),
                _ActionCard(
                  icon: Icons.location_on_rounded,
                  title: 'Guardar GPS',
                  onTap: _saveLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                      'Aún no hay evidencias guardadas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            _EvidencePreview(item: item),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _subtitle(item),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () async {
                                await _service.delete(item.id);
                                _load();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _subtitle(EvidenceItem item) {
    if (item.type == 'location') {
      return '${item.latitude?.toStringAsFixed(5)}, ${item.longitude?.toStringAsFixed(5)}';
    }

    if (item.qrData != null) {
      return item.qrData!;
    }

    return item.createdAt.toString().substring(0, 16);
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvidencePreview extends StatelessWidget {
  final EvidenceItem item;

  const _EvidencePreview({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(item.imagePath!),
          width: 58,
          height: 58,
          fit: BoxFit.cover,
        ),
      );
    }

    if (item.qrData != null && item.type == 'qr_generate') {
      return Container(
        width: 58,
        height: 58,
        padding: const EdgeInsets.all(4),
        color: Colors.white,
        child: QrImageView(data: item.qrData!),
      );
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        item.type == 'location'
            ? Icons.location_on_rounded
            : Icons.qr_code_scanner_rounded,
        color: AppColors.primary,
      ),
    );
  }
}