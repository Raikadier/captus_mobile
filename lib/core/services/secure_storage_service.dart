import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

/// Servicio para almacenamiento seguro de datos sensibles
/// 
/// Usa:
/// - Keychain en iOS
/// - Keystore en Android
/// 
/// Datos que se guardan aquí:
/// - Tokens de autenticación
/// - Contraseñas
/// - Llaves API
/// - Datos biométricos
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_available_when_unlocked_this_device_only,
    ),
  );

  SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  /// Guardar un dato sensible de forma segura
  Future<void> saveSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      debugPrint('✅ Secure data saved: $key');
    } catch (e) {
      debugPrint('Error saving secure data: $e');
    }
  }

  /// Obtener un dato sensible
  Future<String?> getSecureData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Error reading secure data: $e');
      return null;
    }
  }

  /// Eliminar un dato sensible
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
      debugPrint('✅ Secure data deleted: $key');
    } catch (e) {
      debugPrint('Error deleting secure data: $e');
    }
  }

  /// Eliminar todos los datos sensibles
  Future<void> deleteAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('✅ All secure data deleted');
    } catch (e) {
      debugPrint('Error deleting all secure data: $e');
    }
  }

  /// Guardar token de autenticación
  Future<void> saveAuthToken(String token) async {
    await saveSecureData('auth_token', token);
  }

  /// Obtener token de autenticación
  Future<String?> getAuthToken() async {
    return await getSecureData('auth_token');
  }

  /// Guardar contraseña (raramente recomendado)
  Future<void> savePassword(String password) async {
    await saveSecureData('user_password', password);
  }

  /// Obtener contraseña
  Future<String?> getPassword() async {
    return await getSecureData('user_password');
  }

  /// Guardar clave de API
  Future<void> saveAPIKey(String key, String apiKey) async {
    await saveSecureData('api_key_$key', apiKey);
  }

  /// Obtener clave de API
  Future<String?> getAPIKey(String key) async {
    return await getSecureData('api_key_$key');
  }

  /// Guardar datos de biometría
  Future<void> saveBiometricData(String data) async {
    await saveSecureData('biometric_data', data);
  }

  /// Obtener datos de biometría
  Future<String?> getBiometricData() async {
    return await getSecureData('biometric_data');
  }

  /// Verificar si existe un token válido
  Future<bool> hasValidAuthToken() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Limpiar sesión (eliminar token)
  Future<void> clearSession() async {
    await deleteSecureData('auth_token');
    debugPrint('✅ Session cleared');
  }
}
