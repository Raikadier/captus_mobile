import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/teacher_stats_repository.dart';
import '../../../models/teacher_stats_model.dart';

final teacherStatsRepositoryProvider = Provider((ref) => TeacherStatsRepository());

class SelectedCourseNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void select(String? courseId) => state = courseId;
}

final selectedCourseForStatsProvider = NotifierProvider<SelectedCourseNotifier, String?>(SelectedCourseNotifier.new);

final teacherStatsSummaryProvider = FutureProvider<TeacherStatsSummaryModel>((ref) async {
  final repository = ref.watch(teacherStatsRepositoryProvider);
  final selectedCourseId = ref.watch(selectedCourseForStatsProvider);
  return repository.getTeacherStats(courseId: selectedCourseId);
});

// Alias for consistency with user request
final teacherStudentStatsProvider = teacherStatsSummaryProvider;

final teacherStatsByCourseProvider = teacherStatsSummaryProvider;
