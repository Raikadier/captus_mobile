import 'package:flutter/foundation.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    debugPrint('[API] Local mode – GET $path omitido.');
    return null;
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    debugPrint('[API] Local mode – POST $path omitido.');
    return null;
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    debugPrint('[API] Local mode – PUT $path omitido.');
    return null;
  }

  Future<dynamic> delete(String path) async {
    debugPrint('[API] Local mode – DELETE $path omitido.');
    return null;
  }
}
