import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/course.dart';

class StatisticsTeacherScreen extends StatefulWidget {
  const StatisticsTeacherScreen({super.key});

  @override
  State<StatisticsTeacherScreen> createState() => _StatisticsTeacherScreenState();
}

class _StatisticsTeacherScreenState extends State<StatisticsTeacherScreen> {
  String _selectedCourseId = 'c1';
  final _courses = CourseModel.mockList;

  CourseModel get _selectedCourse =>
      _courses.firstWhere((c) => c.id == _selectedCourseId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Course selector
          Text('Curso', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCourseId,
            dropdownColor: AppColors.surface,
            decoration: const InputDecoration(),
            items: _courses
                .map((c) =>
                    DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedCourseId = v ?? _selectedCourseId),
          ),
          const SizedBox(height: 24),

          // Metrics
          Text(
            _selectedCourse.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              _TeacherMetric(label: 'Tasa de entrega', value: '78%'),
              _TeacherMetric(label: 'Promedio retraso', value: '1.2d'),
              _TeacherMetric(label: 'Estudiantes', value: '24'),
              _TeacherMetric(label: 'En riesgo', value: '3', isAlert: true),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'ESTUDIANTES EN RIESGO',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ..._riskStudents.map((s) => _StudentRow(
                name: s,
                onTap: () => context.push('/teacher/student/1'),
              )),
        ],
      ),
    );
  }

  static const _riskStudents = [
    'Carlos Mendoza',
    'Andrea López',
    'Juan Torres',
  ];
}

class _TeacherMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;

  const _TeacherMetric({
    required this.label,
    required this.value,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAlert ? AppColors.error.withAlpha(25) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? AppColors.error.withAlpha(76) : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isAlert ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _StudentRow({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.error.withAlpha(51), width: 0.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.error.withAlpha(38),
              child: Text(
                name[0],
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('Sin entregar 2+ actividades',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.error)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
