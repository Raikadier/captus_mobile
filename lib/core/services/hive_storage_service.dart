import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Servicio para almacenamiento local persistente con Hive
/// Más robusto y eficiente que SharedPreferences
/// 
/// Casos de uso:
/// - Guardar fotos capturadas localmente
/// - Guardar datos de ubicación
/// - Caché de datos de cursos, tareas, grupos
/// - Historial de lecturas QR
class HiveStorageService {
  static final HiveStorageService _instance = HiveStorageService._internal();
  
  late Box<dynamic> _mainBox;
  late Box<List<dynamic>> _listBox;
  late Box<Map<String, dynamic>> _mapBox;

  HiveStorageService._internal();

  factory HiveStorageService() {
    return _instance;
  }

  /// Inicializar Hive y abrir cajas
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      _mainBox = await Hive.openBox('captus_main');
      _listBox = await Hive.openBox<List<dynamic>>('captus_lists');
      _mapBox = await Hive.openBox<Map<String, dynamic>>('captus_maps');
      
      debugPrint('✅ Hive storage initialized');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Guardar un valor simple
  Future<void> setValue(String key, dynamic value) async {
    try {
      await _mainBox.put(key, value);
    } catch (e) {
      debugPrint('Error saving value: $e');
    }
  }

  /// Obtener un valor simple
  dynamic getValue(String key, {dynamic defaultValue}) {
    try {
      return _mainBox.get(key, defaultValue: defaultValue);
    } catch (e) {
      debugPrint('Error getting value: $e');
      return defaultValue;
    }
  }

  /// Guardar una lista
  Future<void> setList(String key, List<dynamic> list) async {
    try {
      await _listBox.put(key, list);
    } catch (e) {
      debugPrint('Error saving list: $e');
    }
  }

  /// Obtener una lista
  List<dynamic> getList(String key, {List<dynamic> defaultValue = const []}) {
    try {
      return _listBox.get(key, defaultValue: defaultValue) ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting list: $e');
      return defaultValue;
    }
  }

  /// Agregar un elemento a una lista
  Future<void> addToList(String key, dynamic value) async {
    try {
      final list = getList(key);
      list.add(value);
      await setList(key, list);
    } catch (e) {
      debugPrint('Error adding to list: $e');
    }
  }

  /// Guardar un mapa
  Future<void> setMap(String key, Map<String, dynamic> map) async {
    try {
      await _mapBox.put(key, map);
    } catch (e) {
      debugPrint('Error saving map: $e');
    }
  }

  /// Obtener un mapa
  Map<String, dynamic> getMap(String key, {Map<String, dynamic>? defaultValue}) {
    try {
      return _mapBox.get(key, defaultValue: defaultValue) ?? defaultValue ?? {};
    } catch (e) {
      debugPrint('Error getting map: $e');
      return defaultValue ?? {};
    }
  }

  /// Eliminar una clave
  Future<void> deleteKey(String key) async {
    try {
      await _mainBox.delete(key);
      await _listBox.delete(key);
      await _mapBox.delete(key);
    } catch (e) {
      debugPrint('Error deleting key: $e');
    }
  }

  /// Limpiar toda la base de datos
  Future<void> clearAll() async {
    try {
      await _mainBox.clear();
      await _listBox.clear();
      await _mapBox.clear();
      debugPrint('✅ Hive storage cleared');
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }

  /// Guardar fotos capturadas localmente
  /// Devuelve el path relativo para referencia
  Future<void> savePhoto(String taskOrCourseId, String photoPath) async {
    try {
      final key = 'photos_$taskOrCourseId';
      final photos = getList(key);
      
      // Agregar metadatos de la foto
      photos.add({
        'path': photoPath,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await setList(key, photos);
      debugPrint('✅ Photo saved for $taskOrCourseId');
    } catch (e) {
      debugPrint('Error saving photo: $e');
    }
  }

  /// Obtener fotos asociadas a una tarea o curso
  List<dynamic> getPhotos(String taskOrCourseId) {
    try {
      final key = 'photos_$taskOrCourseId';
      return getList(key);
    } catch (e) {
      debugPrint('Error getting photos: $e');
      return [];
    }
  }

  /// Guardar ubicación capturada
  Future<void> saveLocationData(String taskOrCourseId, Map<String, dynamic> locationData) async {
    try {
      final key = 'locations_$taskOrCourseId';
      final locations = getList(key);
      
      locations.add(locationData);
      await setList(key, locations);
      
      debugPrint('✅ Location saved for $taskOrCourseId');
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  /// Guardar escaneo de QR
  Future<void> saveQRScan(String qrCode) async {
    try {
      final key = 'qr_scans';
      final scans = getList(key);
      
      scans.add({
        'code': qrCode,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await setList(key, scans);
      debugPrint('✅ QR scan saved: $qrCode');
    } catch (e) {
      debugPrint('Error saving QR scan: $e');
    }
  }

  /// Obtener historial de escaneos QR
  List<dynamic> getQRScanHistory() {
    try {
      return getList('qr_scans');
    } catch (e) {
      debugPrint('Error getting QR history: $e');
      return [];
    }
  }
}
