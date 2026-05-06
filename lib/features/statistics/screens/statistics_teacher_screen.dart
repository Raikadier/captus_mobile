import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../models/teacher_stats_model.dart';
import '../providers/teacher_stats_provider.dart';

class StatisticsFilterNotifier extends Notifier<TeacherStudentRiskLevel?> {
  @override
  TeacherStudentRiskLevel? build() => null;

  void setFilter(TeacherStudentRiskLevel? value) => state = value;
}

final statisticsFilterProvider =
    NotifierProvider<StatisticsFilterNotifier, TeacherStudentRiskLevel?>(
  StatisticsFilterNotifier.new,
);

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
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teacherStatsSummaryProvider);
            await Future<void>.delayed(const Duration(milliseconds: 300));
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(context, ref),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: _buildCourseSelector(
                    ref,
                    coursesAsync,
                    selectedCourseId,
                  ),
                ),
              ),
              if (stats.totalStudents == 0)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(
                    title: 'No hay estudiantes asociados',
                    message:
                        'No hay estudiantes asociados a tus cursos todavía.',
                    icon: Icons.people_outline_rounded,
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildSummaryGrid(context, stats),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPerformanceChart(stats),
                  ),
                ),
                if (stats.averageGrade == null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.info.withAlpha(40),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ya tienes estudiantes. Crea tareas y califica entregas para activar métricas completas.',
                              style: GoogleFonts.inter(
                                color: AppColors.info,
                                fontSize: 12,
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
        error: (err, _) => _buildErrorState(ref, err),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final canPop = GoRouter.of(context).canPop();

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background.withAlpha(240),
      elevation: 0,
      centerTitle: false,
      leading: canPop
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => context.pop(),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withAlpha(30),
                AppColors.background,
              ],
            ),
          ),
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isExpanded = constraints.maxHeight > 80;

            return Padding(
              padding: EdgeInsets.only(
                left: canPop ? 48 : 16,
                bottom: isExpanded ? 16 : 14,
                right: 72,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estadísticas',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: isExpanded ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (isExpanded)
                    Text(
                      'Rendimiento académico',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
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
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            onPressed: () => ref.invalidate(teacherStatsSummaryProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSelector(
    WidgetRef ref,
    AsyncValue<dynamic> coursesAsync,
    String? selectedId,
  ) {
    return coursesAsync.when(
      data: (courses) {
        if (courses == null || courses.isEmpty) {
          return const SizedBox.shrink();
        }

        final dropdownValue = selectedId ?? 'all';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropdownValue,
              hint: Text(
                'Todos los cursos',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              dropdownColor: AppColors.surface,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              isExpanded: true,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              borderRadius: BorderRadius.circular(16),
              items: [
                const DropdownMenuItem<String>(
                  value: 'all',
                  child: Text('Todos los cursos'),
                ),
                ...courses.map<DropdownMenuItem<String>>(
                  (c) => DropdownMenuItem<String>(
                    value: c.id.toString(),
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                ref
                    .read(selectedCourseForStatsProvider.notifier)
                    .select(value == 'all' ? null : value);
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
        child: const Center(
          child: SizedBox(
            width: 80,
            height: 2,
            child: LinearProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryGrid(
    BuildContext context,
    TeacherStatsSummaryModel stats,
  ) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 4 : 2;
    final aspectRatio = width < 400 ? 1.4 : 1.6;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: aspectRatio,
      children: [
        _buildStatCard(
          'Estudiantes',
          stats.totalStudents.toString(),
          Icons.people_alt_rounded,
          AppColors.info,
        ),
        _buildStatCard(
          'Promedio',
          stats.averageGrade == null
              ? '—'
              : stats.averageGrade!.toStringAsFixed(1),
          Icons.auto_graph_rounded,
          AppColors.primary,
        ),
        _buildStatCard(
          'Calificadas',
          (stats.totalSubmissions - stats.pendingToGrade).toString(),
          Icons.check_circle_outline_rounded,
          AppColors.success,
        ),
        _buildStatCard(
          'Pendientes',
          stats.pendingToGrade.toString(),
          Icons.hourglass_bottom_rounded,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Distribución',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildResponsiveBar(
            'Alto',
            stats.highPerformancePercentage,
            AppColors.success,
          ),
          const SizedBox(height: 16),
          _buildResponsiveBar(
            'Medio',
            stats.mediumPerformancePercentage,
            AppColors.warning,
          ),
          const SizedBox(height: 16),
          _buildResponsiveBar(
            'Riesgo',
            stats.riskPercentage,
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveBar(String label, double percentage, Color color) {
    final safePercentage = percentage.clamp(0.0, 1.0);

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
              '${(safePercentage * 100).toInt()}%',
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
                  width: constraints.maxWidth * safePercentage,
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

  Widget _buildFilters(
    WidgetRef ref,
    TeacherStudentRiskLevel? activeFilter,
  ) {
    final filters = <({TeacherStudentRiskLevel? value, String label})>[
      (value: null, label: 'Todos'),
      (value: TeacherStudentRiskLevel.high, label: 'Alto'),
      (value: TeacherStudentRiskLevel.medium, label: 'Medio'),
      (value: TeacherStudentRiskLevel.risk, label: 'Riesgo'),
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
            final isSelected = activeFilter == filter.value;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: isSelected,
                onSelected: (_) => ref
                    .read(statisticsFilterProvider.notifier)
                    .setFilter(filter.value),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: isSelected ? Colors.black : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
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

  Widget _buildStudentList(
    BuildContext context,
    TeacherStatsSummaryModel stats,
    TeacherStudentRiskLevel? filter,
  ) {
    if (filter != null) {
      final filteredStudents =
          stats.students.where((s) => s.riskLevel == filter).toList();

      if (filteredStudents.isEmpty) return _buildNoResultsInFilter();

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildStudentCard(
            context,
            filteredStudents[index],
          ),
          childCount: filteredStudents.length,
        ),
      );
    }

    final highStudents = stats.students
        .where((s) => s.riskLevel == TeacherStudentRiskLevel.high)
        .toList();
    final mediumStudents = stats.students
        .where((s) => s.riskLevel == TeacherStudentRiskLevel.medium)
        .toList();
    final riskStudents = stats.students
        .where((s) => s.riskLevel == TeacherStudentRiskLevel.risk)
        .toList();

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
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
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
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay estudiantes en esta categoría.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    TeacherStudentStatsModel student,
  ) {
    final hasGrades = student.gradedSubmissions > 0;
    late final Color statusColor;
    late final String statusLabel;

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(student.studentName, statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.studentName,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildMiniBadge(
                            hasGrades && student.averageGrade != null
                                ? student.averageGrade!.toStringAsFixed(1)
                                : '—',
                            hasGrades ? statusColor : AppColors.textDisabled,
                            Icons.star_rounded,
                            filled: hasGrades,
                          ),
                          Text(
                            '${(student.completionRate * 100).toInt()}% ent.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${student.submittedAssignments}/${student.totalAssignments}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
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
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(60),
            color.withAlpha(20),
          ],
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

  Widget _buildMiniBadge(
    String text,
    Color color,
    IconData icon, {
    bool filled = false,
  }) {
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

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
              child: Icon(
                icon,
                size: 80,
                color: AppColors.primary.withAlpha(100),
              ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar estadísticas',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No se pudo conectar con el servidor. Por favor, verifica tu conexión.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(teacherStatsSummaryProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
  double get minExtent => 62;

  @override
  double get maxExtent => 62;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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