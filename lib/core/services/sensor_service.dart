import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/material.dart';

/// Modelo para ubicación
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'altitude': altitude,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    latitude: json['latitude'] as double? ?? 0,
    longitude: json['longitude'] as double? ?? 0,
    accuracy: json['accuracy'] as double?,
    altitude: json['altitude'] as double?,
    timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
  );
}

/// Modelo para datos de acelerómetro
class AccelerometerData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Calcula la magnitud total de aceleración
  double get magnitude => (x * x + y * y + z * z);

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
    'magnitude': magnitude,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Servicio para acceder a sensores del dispositivo
/// - GPS / Geolocalización
/// - Acelerómetro
/// - Giroscopio
/// - Magnetómetro
/// 
/// Casos de uso en Captus:
/// - Guardar ubicación donde se tomó foto de tarea
/// - Detectar cuando el estudiante "mueve el dispositivo" para validar asistencia
/// - Registrar patrones de actividad del usuario
class SensorService {
  static final SensorService _instance = SensorService._internal();
  
  LocationData? _lastLocation;
  AccelerometerData? _lastAccelerometer;

  SensorService._internal();

  factory SensorService() {
    return _instance;
  }

  /// Obtener permiso de ubicación y localización actual
  Future<LocationData?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _lastLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
      );

      return _lastLocation;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Obtener la última ubicación conocida
  LocationData? get lastLocation => _lastLocation;

  /// Stream de cambios de ubicación (en tiempo real)
  Stream<LocationData> getLocationStream() async* {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      final positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Actualizar cada 10 metros
        ),
      );

      await for (final position in positionStream) {
        yield LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
        );
      }
    } catch (e) {
      debugPrint('Error in location stream: $e');
    }
  }

  /// Obtener datos actuales del acelerómetro
  Future<AccelerometerData?> getAccelerometerData() async {
    try {
      final events = await accelerometerEvents.first;
      _lastAccelerometer = AccelerometerData(
        x: events.x,
        y: events.y,
        z: events.z,
      );
      return _lastAccelerometer;
    } catch (e) {
      debugPrint('Error getting accelerometer data: $e');
      return null;
    }
  }

  /// Stream de eventos del acelerómetro
  Stream<AccelerometerData> getAccelerometerStream() async* {
    try {
      await for (final event in accelerometerEvents) {
        yield AccelerometerData(
          x: event.x,
          y: event.y,
          z: event.z,
        );
      }
    } catch (e) {
      debugPrint('Error in accelerometer stream: $e');
    }
  }

  /// Obtener la última lectura de acelerómetro
  AccelerometerData? get lastAccelerometerData => _lastAccelerometer;

  /// Detectar movimiento rápido (para validar asistencia)
  /// Retorna true si detecta movimiento brusco
  Future<bool> detectRapidMovement({double threshold = 30.0}) async {
    try {
      final accel = await getAccelerometerData();
      if (accel == null) return false;
      return accel.magnitude > threshold;
    } catch (e) {
      debugPrint('Error detecting movement: $e');
      return false;
    }
  }
}
