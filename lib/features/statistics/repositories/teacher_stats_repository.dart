import '../../../models/teacher_stats_model.dart';

abstract class TeacherStatsRepository {
  Future<TeacherStatsSummaryModel> getTeacherStats({String? courseId});
}
