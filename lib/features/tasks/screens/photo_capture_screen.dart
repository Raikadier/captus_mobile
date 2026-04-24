import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/sensor_service.dart';
import '../../../core/services/hive_storage_service.dart';

/// Pantalla para capturar fotos de tareas
/// Las fotos se asocian a la tarea y se guardan localmente
class PhotoCaptureScreen extends ConsumerStatefulWidget {
  final String taskId;
  final String taskTitle;

  const PhotoCaptureScreen({
    Key? key,
    required this.taskId,
    required this.taskTitle,
  }) : super(key: key);

  @override
  ConsumerState<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends ConsumerState<PhotoCaptureScreen> {
  final CameraService _camera = CameraService();
  final SensorService _sensor = SensorService();
  final HiveStorageService _storage = HiveStorageService();

  List<File> _capturedPhotos = [];
  LocationData? _currentLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _getCurrentLocation();
  }

  void _loadPhotos() {
    final photos = _storage.getPhotos(widget.taskId);
    setState(() {
      _capturedPhotos = photos
          .map((p) => File(p['path'] as String))
          .where((f) => f.existsSync())
          .toList();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final location = await _sensor.getCurrentLocation();
      setState(() => _currentLocation = location);
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _capturePhoto() async {
    final photo = await _camera.capturePhoto();
    if (photo != null) {
      // Guardar información de la foto
      await _storage.savePhoto(widget.taskId, photo.path);

      // Si tenemos ubicación, guardarla también
      if (_currentLocation != null) {
        await _storage.saveLocationData(
          widget.taskId,
          _currentLocation!.toJson(),
        );
      }

      _loadPhotos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Foto guardada exitosamente'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    final photo = await _camera.pickPhotoFromGallery();
    if (photo != null) {
      await _storage.savePhoto(widget.taskId, photo.path);
      _loadPhotos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Foto añadida exitosamente'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deletePhoto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Estás seguro de que quieres eliminar esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _capturedPhotos.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Foto eliminada'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de ubicación
              if (_currentLocation != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ubicación capturada',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_currentLocation!.latitude.toStringAsFixed(4)}, '
                                '${_currentLocation!.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_currentLocation == null && _isLoadingLocation)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: CircularProgressIndicator(),
                ),

              const SizedBox(height: 24),

              // Título de fotos
              Text(
                'Fotos de la tarea (${_capturedPhotos.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              // Galería de fotos
              if (_capturedPhotos.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hay fotos capturadas',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _capturedPhotos.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _showPhotoDialog(_capturedPhotos[index]),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_capturedPhotos[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: FloatingActionButton.small(
                            heroTag: 'delete_$index',
                            backgroundColor: Colors.red,
                            onPressed: () => _deletePhoto(index),
                            child: const Icon(Icons.delete),
                          ),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _capturePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Capturar foto'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickPhotoFromGallery,
                      icon: const Icon(Icons.image),
                      label: const Text('Galería'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Botón de finalizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _capturedPhotos.isNotEmpty
                      ? () => Navigator.pop(context, _capturedPhotos)
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Enviar tarea'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoDialog(File photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.file(photo),
      ),
    );
  }
}
