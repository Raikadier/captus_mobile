import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/sensor_service.dart';
import '../../../core/services/local_notification_service.dart';

/// Pantalla para registrar asistencia usando sensores
/// Detecta que el dispositivo se mueve para validar asistencia activa
class AttendanceScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;

  const AttendanceScreen({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final SensorService _sensor = SensorService();
  final LocalNotificationService _notifications = LocalNotificationService();

  bool _isRegistered = false;
  bool _movementDetected = false;
  LocationData? _location;
  int _movementCount = 0;

  late Stream<AccelerometerData> _accelerometerStream;

  @override
  void initState() {
    super.initState();
    _registerAttendance();
    _listenToSensors();
  }

  Future<void> _registerAttendance() async {
    try {
      // Obtener ubicación
      final location = await _sensor.getCurrentLocation();
      
      setState(() {
        _isRegistered = true;
        _location = location;
      });

      // Mostrar notificación
      await _notifications.showNotification(
        id: widget.courseId.hashCode,
        title: '✅ Asistencia Registrada',
        body: 'Te has registrado en ${widget.courseName}',
      );
    } catch (e) {
      debugPrint('Error registering attendance: $e');
    }
  }

  void _listenToSensors() {
    _accelerometerStream = _sensor.getAccelerometerStream();
    _accelerometerStream.listen((event) {
      // Detectar movimiento brusco (magnitud > 30)
      if (event.magnitude > 30) {
        if (!_movementDetected) {
          setState(() {
            _movementDetected = true;
            _movementCount++;
          });

          // Resetear después de 1 segundo
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() => _movementDetected = false);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Estado de asistencia
                if (_isRegistered)
                  Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¡Asistencia Registrada!',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                // Ubicación
                if (_location != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(height: 8),
                          const Text('Ubicación'),
                          const SizedBox(height: 4),
                          Text(
                            '${_location!.latitude.toStringAsFixed(4)}, '
                            '${_location!.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Detector de movimiento
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _movementDetected ? Colors.green.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _movementDetected ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Sensor de Movimiento',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Icon(
                        _movementDetected ? Icons.vibration : Icons.mood,
                        size: 64,
                        color: _movementDetected ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _movementDetected ? '¡Movimiento detectado!' : 'Mueve el dispositivo',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Movimientos detectados: $_movementCount',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Información
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ℹ️ Información',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Tu ubicación ha sido registrada\n'
                          '• El sensor detecta movimiento del dispositivo\n'
                          '• Los datos se almacenan localmente\n'
                          '• Puedes cerrar la pantalla cuando quieras',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botones
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, {
                    'courseId': widget.courseId,
                    'location': _location?.toJson(),
                    'movementsDetected': _movementCount,
                  }),
                  icon: const Icon(Icons.check),
                  label: const Text('Finalizar Asistencia'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
