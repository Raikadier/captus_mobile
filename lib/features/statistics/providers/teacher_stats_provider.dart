import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/teacher_stats_repository.dart';
import '../repositories/supabase_teacher_stats_repository.dart';
import '../../../models/teacher_stats_model.dart';

final teacherStatsRepositoryProvider = Provider<TeacherStatsRepository>((ref) {
  return SupabaseTeacherStatsRepository();
});

class SelectedCourseNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void select(String? courseId) => state = courseId;
}

final selectedCourseForStatsProvider = NotifierProvider<SelectedCourseNotifier, String?>(SelectedCourseNotifier.new);

final teacherStatsSummaryProvider = FutureProvider<TeacherStatsSummaryModel>((ref) async {
  final repository = ref.watch(teacherStatsRepositoryProvider);
  final selectedCourseId = ref.watch(selectedCourseForStatsProvider);
  
  // No need for try-catch here as the repository already handles it 
  // and returns an empty model or specific data.
  return repository.getTeacherStats(courseId: selectedCourseId);
});

// Alias for backwards compatibility if needed
final teacherStudentStatsProvider = teacherStatsSummaryProvider;
final teacherStatsByCourseProvider = teacherStatsSummaryProvider;
