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

  Future<Map<String, dynamic>> updateCourse(
      String courseId, Map<String, dynamic> data) async {
    final res = await ApiClient.instance
        .put<Map<String, dynamic>>('$_base/courses/$courseId', data: data);
    return res.data ?? {};
  }

  Future<List<dynamic>> getCourseStudents(String courseId) async {
    final res = await ApiClient.instance
        .get<List<dynamic>>('$_base/courses/$courseId/students');
    return res.data ?? [];
  }

  Future<void> unenrollStudent(String courseId, String studentId) async {
    await ApiClient.instance
        .delete<void>('$_base/courses/$courseId/students/$studentId');
  }

  Future<Map<String, dynamic>> broadcastNotification({
    required String title,
    String? body,
    String? role,
  }) async {
    final res = await ApiClient.instance.post<Map<String, dynamic>>(
      '$_base/notifications/broadcast',
      data: {
        'title': title,
        if (body != null && body.isNotEmpty) 'body': body,
        if (role != null) 'role': role,
      },
    );
    return res.data ?? {};
  }

  // ── Grading Scales ───────────────────────────────────────────────────────

  Future<List<dynamic>> getGradingScales() async {
    final res = await ApiClient.instance.get<List<dynamic>>('$_base/grading-scales');
    return res.data ?? [];
  }

  Future<Map<String, dynamic>> createGradingScale(Map<String, dynamic> data) async {
    final res = await ApiClient.instance
        .post<Map<String, dynamic>>('$_base/grading-scales', data: data);
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> updateGradingScale(
      String id, Map<String, dynamic> data) async {
    final res = await ApiClient.instance
        .put<Map<String, dynamic>>('$_base/grading-scales/$id', data: data);
    return res.data ?? {};
  }

  Future<void> deleteGradingScale(String id) async {
    await ApiClient.instance.delete<void>('$_base/grading-scales/$id');
  }

  Future<void> setDefaultGradingScale(String id) async {
    await ApiClient.instance
        .patch<void>('$_base/grading-scales/$id/set-default', data: {});
  }

  // ── Academic Periods ─────────────────────────────────────────────────────

  Future<List<dynamic>> getPeriods() async {
    final res = await ApiClient.instance.get<List<dynamic>>('$_base/periods');
    return res.data ?? [];
  }

  Future<Map<String, dynamic>> createPeriod(Map<String, dynamic> data) async {
    final res = await ApiClient.instance
        .post<Map<String, dynamic>>('$_base/periods', data: data);
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> updatePeriod(
      String id, Map<String, dynamic> data) async {
    final res = await ApiClient.instance
        .put<Map<String, dynamic>>('$_base/periods/$id', data: data);
    return res.data ?? {};
  }

  Future<void> deletePeriod(String id) async {
    await ApiClient.instance.delete<void>('$_base/periods/$id');
  }

  Future<void> setActivePeriod(String id) async {
    await ApiClient.instance
        .patch<void>('$_base/periods/$id/set-active', data: {});
  }
}
