import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/teacher_stats_provider.dart';
import '../../../models/teacher_stats_model.dart';
import '../../../core/providers/courses_provider.dart';

class StatisticsTeacherScreen extends ConsumerWidget {
  const StatisticsTeacherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(teacherStatsSummaryProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final selectedCourseId = ref.watch(selectedCourseForStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Estadísticas',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(teacherStatsSummaryProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats.totalStudents == 0 && stats.totalAssignments == 0) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(teacherStatsSummaryProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourseSelector(ref, coursesAsync, selectedCourseId),
                  const SizedBox(height: 20),
                  _buildSummaryGrid(stats),
                  const SizedBox(height: 24),
                  _buildPerformanceBreakdown(stats),
                  const SizedBox(height: 24),
                  _buildStudentsByCategory(stats),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(ref, err),
      ),
    );
  }

  Widget _buildCourseSelector(WidgetRef ref, AsyncValue coursesAsync, String? selectedId) {
    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selectedId,
              hint: Text('Todos los cursos', style: GoogleFonts.inter(color: AppColors.textSecondary)),
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos los cursos'),
                ),
                ...courses.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                )),
              ],
              onChanged: (val) {
                ref.read(selectedCourseForStatsProvider.notifier).select(val);
              },
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryGrid(TeacherStatsSummaryModel stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Estudiantes',
          stats.totalStudents.toString(),
          Icons.people_rounded,
          AppColors.info,
        ),
        _buildStatCard(
          'Tareas',
          stats.totalAssignments.toString(),
          Icons.assignment_rounded,
          AppColors.primary,
        ),
        _buildStatCard(
          'Promedio',
          stats.averageGrade.toStringAsFixed(1),
          Icons.analytics_rounded,
          AppColors.warning,
        ),
        _buildStatCard(
          'Por Calificar',
          stats.pendingToGrade.toString(),
          Icons.pending_actions_rounded,
          AppColors.error,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown(TeacherStatsSummaryModel stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rendimiento Académico',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressBar('Alto Rendimiento', stats.highPerformancePercentage, AppColors.success),
          const SizedBox(height: 16),
          _buildProgressBar('Rendimiento Medio', stats.mediumPerformancePercentage, AppColors.warning),
          const SizedBox(height: 16),
          _buildProgressBar('En Riesgo', stats.riskPercentage, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            Text('${(percentage * 100).toInt()}%', 
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withAlpha(25),
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsByCategory(TeacherStatsSummaryModel stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estudiantes por Categoría',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (stats.students.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('No hay estudiantes con datos registrados.', 
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.students.length,
            itemBuilder: (context, index) {
              final student = stats.students[index];
              return _buildStudentItem(student);
            },
          ),
      ],
    );
  }

  Widget _buildStudentItem(TeacherStudentStatsModel student) {
    Color riskColor;
    String riskLabel;
    switch (student.riskLevel) {
      case RiskLevel.low:
        riskColor = AppColors.success;
        riskLabel = 'Alto';
        break;
      case RiskLevel.medium:
        riskColor = AppColors.warning;
        riskLabel = 'Medio';
        break;
      case RiskLevel.high:
        riskColor = AppColors.error;
        riskLabel = 'Riesgo';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: riskColor.withAlpha(25),
            child: Text(
              student.studentName.isNotEmpty ? student.studentName[0] : 'S',
              style: GoogleFonts.inter(color: riskColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  'Promedio: ${student.averageGrade.toStringAsFixed(1)} • Entregas: ${student.submittedAssignments}/${student.totalAssignments}',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: riskColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              riskLabel,
              style: GoogleFonts.inter(
                color: riskColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(
            'Sin datos disponibles',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tareas y califica entregas para ver estadísticas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar estadísticas',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(teacherStatsSummaryProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
