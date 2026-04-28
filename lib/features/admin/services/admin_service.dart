import '../../../core/services/api_client.dart';

const _base = '/admin';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  // ── Stats & Institution ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    final res = await ApiClient.instance.get<Map<String, dynamic>>('$_base/stats');
    return res.data ?? {};
  }

  Future<Map<String, dynamic>?> getInstitution() async {
    final res = await ApiClient.instance.get<Map<String, dynamic>>('$_base/institution');
    return res.data;
  }

  Future<Map<String, dynamic>> updateInstitution(
    String id,
    Map<String, dynamic> data,
  ) async {
    final res = await ApiClient.instance
        .put<Map<String, dynamic>>('$_base/institution/$id', data: data);
    return res.data ?? {};
  }

  // ── Users ────────────────────────────────────────────────────────────────

  Future<List<dynamic>> getMembers({String? role}) async {
    final res = await ApiClient.instance.get<List<dynamic>>(
      '$_base/users',
      queryParameters: role != null ? {'role': role} : null,
    );
    return res.data ?? [];
  }

  Future<void> inviteUser(String email, String role) async {
    await ApiClient.instance.post<void>(
      '$_base/users/invite',
      data: {'email': email, 'role': role},
    );
  }

  Future<void> removeUser(String userId) async {
    await ApiClient.instance.delete<void>('$_base/users/$userId');
  }

  Future<void> changeUserRole(String userId, String newRole) async {
    await ApiClient.instance.patch<void>(
      '$_base/users/$userId/role',
      data: {'role': newRole},
    );
  }

  // ── Courses ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> getCourses() async {
    final res = await ApiClient.instance.get<List<dynamic>>('$_base/courses');
    return res.data ?? [];
  }

  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> data) async {
    final res =
        await ApiClient.instance.post<Map<String, dynamic>>('$_base/courses', data: data);
    return res.data ?? {};
  }

  Future<void> assignTeacher(String courseId, String teacherId) async {
    await ApiClient.instance.post<void>(
      '$_base/courses/$courseId/assign-teacher',
      data: {'teacherId': teacherId},
    );
  }

  Future<Map<String, dynamic>> bulkEnroll(
    String courseId,
    List<String> emails,
  ) async {
    final res = await ApiClient.instance.post<Map<String, dynamic>>(
      '$_base/courses/$courseId/bulk-enroll',
      data: {'emails': emails},
    );
    return res.data ?? {};
  }
}
