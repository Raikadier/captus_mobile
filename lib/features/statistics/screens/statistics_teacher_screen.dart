import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/teacher_stats_provider.dart';
import '../../../models/teacher_stats_model.dart';
import '../../../core/providers/courses_provider.dart';

class StatisticsFilterNotifier extends Notifier<TeacherStudentRiskLevel?> {
  @override
  TeacherStudentRiskLevel? build() => null;
  
  void setFilter(TeacherStudentRiskLevel? value) => state = value;
}

final statisticsFilterProvider = NotifierProvider<StatisticsFilterNotifier, TeacherStudentRiskLevel?>(StatisticsFilterNotifier.new);

class StatisticsTeacherScreen extends ConsumerWidget {
  const StatisticsTeacherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(teacherStatsSummaryProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final selectedCourseId = ref.watch(selectedCourseForStatsProvider);
    final activeFilter = ref.watch(statisticsFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            left: -100,
            child: _buildBlurCircle(300, AppColors.primary.withAlpha(15)),
          ),
          Positioned(
            bottom: 200,
            right: -150,
            child: _buildBlurCircle(400, AppColors.info.withAlpha(10)),
          ),
          
          statsAsync.when(
            data: (stats) => RefreshIndicator(
              onRefresh: () async => ref.refresh(teacherStatsSummaryProvider),
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBar(context, ref),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: _buildCourseSelector(ref, coursesAsync, selectedCourseId),
                    ),
                  ),
                  if (stats.totalStudents == 0)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(
                        title: 'No hay estudiantes asociados',
                        message: 'No hay estudiantes asociados a tus cursos todavía.',
                        icon: Icons.people_outline_rounded,
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildSummaryGrid(stats),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildPerformanceChart(stats),
                      ),
                    ),
                    if (stats.totalStudents > 0 && stats.averageGrade == null)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.info.withAlpha(40)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.info),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ya tienes estudiantes. Crea tareas y califica entregas para activar métricas completas.',
                                  style: GoogleFonts.inter(
                                    color: AppColors.info,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverHeaderDelegate(
                        child: _buildFilters(ref, activeFilter),
                      ),
                    ),
                    _buildStudentList(context, stats, activeFilter),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ],
              ),
            ),
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Cargando estadísticas...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            error: (err, stack) => _buildErrorState(ref, err),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background.withAlpha(230),
      elevation: 0,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withAlpha(40),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            // Decorative shapes
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha(10),
                ),
              ),
            ),
          ],
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isExpanded = constraints.maxHeight > 100;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                bottom: isExpanded ? 20 : 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estadísticas docentes',
                    style: GoogleFonts.outfit(
                      fontSize: isExpanded ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (isExpanded)
                    Text(
                      'Seguimiento de rendimiento estudiantil',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
            ),
            onPressed: () => ref.invalidate(teacherStatsSummaryProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildCourseSelector(WidgetRef ref, AsyncValue coursesAsync, String? selectedId) {
    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selectedId,
              hint: Text('Todos los cursos', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 24),
              isExpanded: true,
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
              borderRadius: BorderRadius.circular(16),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos los cursos'),
                ),
                ...courses.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                )),
              ],
              onChanged: (val) {
                ref.read(selectedCourseForStatsProvider.notifier).select(val);
              },
            ),
          ),
        );
      },
      loading: () => Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: SizedBox(width: 20, height: 2, child: LinearProgressIndicator())),
      ),
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
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(
          'Total estudiantes',
          stats.totalStudents.toString(),
          Icons.people_alt_rounded,
          AppColors.info,
        ),
        _buildStatCard(
          'Promedio general',
          stats.averageGrade == null ? '—' : stats.averageGrade!.toStringAsFixed(1),
          Icons.auto_graph_rounded,
          AppColors.primary,
        ),
        _buildStatCard(
          'Entregas calificadas',
          (stats.totalSubmissions - stats.pendingToGrade).toString(),
          Icons.check_circle_outline_rounded,
          AppColors.success,
        ),
        _buildStatCard(
          'Pendientes por calificar',
          stats.pendingToGrade.toString(),
          Icons.hourglass_bottom_rounded,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 0.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withAlpha(180),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(TeacherStatsSummaryModel stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 0.5),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.surface,
            AppColors.surface2.withAlpha(150),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Distribución académica',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildResponsiveBar('Alto rendimiento', stats.highPerformancePercentage, AppColors.success),
          const SizedBox(height: 22),
          _buildResponsiveBar('Rendimiento medio', stats.mediumPerformancePercentage, AppColors.warning),
          const SizedBox(height: 22),
          _buildResponsiveBar('En riesgo / seguimiento', stats.riskPercentage, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildResponsiveBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${(percentage * 100).toInt()}%',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface3,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  height: 12,
                  width: constraints.maxWidth * percentage.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        color.withAlpha(100),
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters(WidgetRef ref, TeacherStudentRiskLevel? activeFilter) {
    final filters = [
      (null, 'Todos'),
      (TeacherStudentRiskLevel.high, 'Alto'),
      (TeacherStudentRiskLevel.medium, 'Medio'),
      (TeacherStudentRiskLevel.risk, 'Riesgo'),
    ];

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = activeFilter == filter.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(filter.$2),
                selected: isSelected,
                onSelected: (_) => ref.read(statisticsFilterProvider.notifier).setFilter(filter.$1),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: isSelected ? Colors.black : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 0.5,
                  ),
                ),
                showCheckmark: false,
                elevation: isSelected ? 4 : 0,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStudentList(BuildContext context, TeacherStatsSummaryModel stats, TeacherStudentRiskLevel? filter) {
    if (filter != null) {
      final filteredStudents = stats.students.where((s) => s.riskLevel == filter).toList();
      if (filteredStudents.isEmpty) return _buildNoResultsInFilter();
      
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildStudentCard(context, filteredStudents[index]),
          childCount: filteredStudents.length,
        ),
      );
    }

    // Default view: Grouped by category
    final highStudents = stats.students.where((s) => s.riskLevel == TeacherStudentRiskLevel.high).toList();
    final mediumStudents = stats.students.where((s) => s.riskLevel == TeacherStudentRiskLevel.medium).toList();
    final riskStudents = stats.students.where((s) => s.riskLevel == TeacherStudentRiskLevel.risk).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        if (highStudents.isNotEmpty) ...[
          _buildCategoryHeader('Alto rendimiento', AppColors.success),
          ...highStudents.map((s) => _buildStudentCard(context, s)),
        ],
        if (mediumStudents.isNotEmpty) ...[
          _buildCategoryHeader('Rendimiento medio', AppColors.warning),
          ...mediumStudents.map((s) => _buildStudentCard(context, s)),
        ],
        if (riskStudents.isNotEmpty) ...[
          _buildCategoryHeader('En riesgo / seguimiento', AppColors.error),
          ...riskStudents.map((s) => _buildStudentCard(context, s)),
        ],
      ]),
    );
  }

  Widget _buildCategoryHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsInFilter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              'No hay estudiantes en esta categoría.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, TeacherStudentStatsModel student) {
    final hasGrades = student.gradedSubmissions > 0;
    Color statusColor;
    String statusLabel;
    
    switch (student.riskLevel) {
      case TeacherStudentRiskLevel.high:
        statusColor = AppColors.success;
        statusLabel = 'Excelente';
        break;
      case TeacherStudentRiskLevel.medium:
        statusColor = AppColors.warning;
        statusLabel = 'Regular';
        break;
      case TeacherStudentRiskLevel.risk:
        statusColor = AppColors.error;
        statusLabel = hasGrades ? 'En Riesgo' : 'En Seguimiento';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 0.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface2.withAlpha(100),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            try {
              context.push('/teacher/student/${student.studentId}');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(student.studentName, statusColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.studentName,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMiniBadge(
                            hasGrades && student.averageGrade != null 
                                ? student.averageGrade!.toStringAsFixed(1) 
                                : 'S/N',
                            hasGrades ? statusColor : AppColors.textDisabled,
                            Icons.star_rounded,
                            filled: hasGrades,
                          ),
                          const SizedBox(width: 12),
                          _buildMiniBadge(
                            '${(student.completionRate * 100).toInt()}% cumpl.',
                            AppColors.textSecondary,
                            Icons.task_alt_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withAlpha(50), width: 0.5),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.assignment_turned_in_outlined, size: 12, color: AppColors.textDisabled),
                        const SizedBox(width: 4),
                        Text(
                          '${student.submittedAssignments}/${student.totalAssignments}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, Color color) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(60), color.withAlpha(20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(100), width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color, IconData icon, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(30) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: filled ? color.withAlpha(60) : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withAlpha(filled ? 255 : 180)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withAlpha(filled ? 255 : 180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required String title, required String message, required IconData icon}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(20),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, size: 80, color: AppColors.primary.withAlpha(100)),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar estadísticas',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'No se pudo conectar con el servidor. Por favor, verifica tu conexión.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(teacherStatsSummaryProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverHeaderDelegate({required this.child});

  @override
  double get minExtent => 62.0;
  @override
  double get maxExtent => 62.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
