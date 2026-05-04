import '../../../core/services/api_client.dart';

/// Service layer for all /api/superadmin endpoints.
/// Only users with role 'superadmin' should reach these.
class SuperAdminService {
  final ApiClient _api = ApiClient.instance;

  // ── Platform stats ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPlatformStats() async {
    final res = await _api.get('/superadmin/stats');
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ── Institutions ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> listInstitutions({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    final res = await _api.get('/superadmin/institutions', queryParameters: {
      'page': page,
      'limit': limit,
      if (search.isNotEmpty) 'search': search,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getInstitution(String id) async {
    final res = await _api.get('/superadmin/institutions/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateInstitution(
      String id, Map<String, dynamic> data) async {
    final res = await _api.put('/superadmin/institutions/$id', data: data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> disableInstitution(
      String id, String reason) async {
    final res = await _api.patch(
      '/superadmin/institutions/$id/disable',
      data: {'reason': reason},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> enableInstitution(String id) async {
    final res = await _api.patch('/superadmin/institutions/$id/enable');
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ── Users (global) ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> listUsers({
    int page = 1,
    int limit = 20,
    String search = '',
    String? role,
    String? institutionId,
  }) async {
    final res = await _api.get('/superadmin/users', queryParameters: {
      'page': page,
      'limit': limit,
      if (search.isNotEmpty) 'search': search,
      if (role != null) 'role': role,
      if (institutionId != null) 'institutionId': institutionId,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> changeUserRole(
      String userId, String newRole) async {
    final res = await _api.patch(
      '/superadmin/users/$userId/role',
      data: {'role': newRole},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> removeUserFromInstitution(String userId) async {
    await _api.delete('/superadmin/users/$userId/institution');
  }

  // ── Audit log ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAuditLog({int page = 1}) async {
    final res = await _api.get('/superadmin/audit-log',
        queryParameters: {'page': page});
    return Map<String, dynamic>.from(res.data as Map);
  }
}
