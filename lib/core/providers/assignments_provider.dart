import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/assignments/repositories/assignments_repository.dart';
import '../../features/assignments/repositories/local_assignments_repository.dart';
import '../../features/assignments/repositories/supabase_assignments_repository.dart';
import '../../../models/assignment.dart';
import '../../../models/submission.dart';
import 'auth_provider.dart';

import '../env/env.dart';

// -----------------------------------------------------------------------------
// CAMBIO DE ENTORNO DINAMICO: LOCAL vs SUPABASE
// -----------------------------------------------------------------------------
final assignmentsRepositoryProvider = Provider<AssignmentsRepository>((ref) {
  if (Env.hasSupabase) {
    return SupabaseAssignmentsRepository();
  }
  return LocalAssignmentsRepository();
});

// -----------------------------------------------------------------------------
// 1. TeacherAssignmentsNotifier
// -----------------------------------------------------------------------------
class TeacherAssignmentsNotifier extends AsyncNotifier<List<AssignmentModel>> {
  @override
  Future<List<AssignmentModel>> build() async {
    return _fetchAssignments();
  }

  Future<List<AssignmentModel>> _fetchAssignments() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return [];
    final repo = ref.read(assignmentsRepositoryProvider);
    return await repo.getAssignmentsByTeacher(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAssignments());
  }

  Future<AssignmentModel?> createAssignment(AssignmentModel assignment) async {
    try {
      final repo = ref.read(assignmentsRepositoryProvider);
      final newAssignment = await repo.createAssignment(assignment);
      state = state.whenData((assignments) => [...assignments, newAssignment]);
      return newAssignment;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> updateAssignment(AssignmentModel assignment) async {
    try {
      final repo = ref.read(assignmentsRepositoryProvider);
      final updated = await repo.updateAssignment(assignment);
      state = state.whenData((assignments) =>
          assignments.map((a) => a.id == updated.id ? updated : a).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    try {
      final repo = ref.read(assignmentsRepositoryProvider);
      await repo.deleteAssignment(assignmentId);
      state = state.whenData((assignments) =>
          assignments.where((a) => a.id != assignmentId).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> assignToGroup(String assignmentId, String groupId) async {
    try {
      final repo = ref.read(assignmentsRepositoryProvider);
      await repo.assignToGroup(assignmentId, groupId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> assignToStudent(String assignmentId, String studentId) async {
    try {
      final repo = ref.read(assignmentsRepositoryProvider);
      await repo.assignToStudent(assignmentId, studentId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> gradeSubmission(String assignmentId, String submissionId,
      double grade, String feedback) async {
    try {
      final repo = ref.read(assignmentsRepositoryProvider);
      await repo.gradeSubmission(submissionId, grade, feedback);
      ref.invalidate(submissionsProvider(assignmentId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final teacherAssignmentsProvider =
    AsyncNotifierProvider<TeacherAssignmentsNotifier, List<AssignmentModel>>(
  TeacherAssignmentsNotifier.new,
);

// -----------------------------------------------------------------------------
// 2. StudentAssignmentsNotifier
// -----------------------------------------------------------------------------
class StudentAssignmentsNotifier extends AsyncNotifier<List<AssignmentModel>> {
  @override
  Future<List<AssignmentModel>> build() async {
    return _fetchAssignments();
  }

  Future<List<AssignmentModel>> _fetchAssignments() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return [];
    final repo = ref.read(assignmentsRepositoryProvider);
    return await repo.getAssignmentsForStudent(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAssignments());
  }

  Future<SubmissionModel?> createSubmission(SubmissionModel submission) async {
    try {
      final repo = ref.read(assignmentsRepositoryProvider);
      final newSub = await repo.createSubmission(submission);
      // Invalidate the submissions so if they check it again it's updated
      ref.invalidate(submissionsProvider(submission.assignmentId));
      return newSub;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final studentAssignmentsProvider =
    AsyncNotifierProvider<StudentAssignmentsNotifier, List<AssignmentModel>>(
  StudentAssignmentsNotifier.new,
);

// -----------------------------------------------------------------------------
// 3. SubmissionsProvider (Family)
// -----------------------------------------------------------------------------
final submissionsProvider =
    FutureProvider.family<List<SubmissionModel>, String>(
        (ref, assignmentId) async {
  final repo = ref.read(assignmentsRepositoryProvider);
  return await repo.getSubmissionsByAssignment(assignmentId);
});

// -----------------------------------------------------------------------------
// 4. TeacherStatsProvider
// -----------------------------------------------------------------------------
final teacherStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return {};

  final repo = ref.read(assignmentsRepositoryProvider);
  return await repo.getTeacherStats(user.id);
});

// -----------------------------------------------------------------------------
// 5. RecentSubmissionsProvider
// -----------------------------------------------------------------------------
final recentSubmissionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return [];

  final repo = ref.read(assignmentsRepositoryProvider);
  return await repo.getRecentSubmissionsByTeacher(user.id, limit: 5);
});
