import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class StudentProfileViewScreen extends StatelessWidget {
  final String studentId;
  const StudentProfileViewScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      restorationId: 'student_profile_view_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil del estudiante'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s4),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryDark,
                  child: Text(
                    'C',
                    style: tt.displaySmall!.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  'Carlos Mendoza',
                  style: tt.headlineMedium!.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  'carlos.mendoza@unicesar.edu.co',
                  style: tt.bodySmall!.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s6),

          // Stats
          Row(
            children: [
              _StudentStat(label: 'Entregas', value: '6/10'),
              const SizedBox(width: AppSpacing.s3),
              _StudentStat(label: 'A tiempo', value: '60%'),
              const SizedBox(width: AppSpacing.s3),
              _StudentStat(label: 'Promedio', value: '3.5'),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),

          Text(
            'ENTREGAS EN ESTE CURSO',
            style: tt.labelMedium!.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s3),
          ..._submissions.map((s) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.s2),
                padding: const EdgeInsets.all(AppSpacing.s3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['title']!,
                              style: tt.titleSmall),
                          Text(s['date']!,
                              style: tt.labelMedium!.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: s['status'] == 'Entregada'
                            ? AppColors.primary.withAlpha(AppAlpha.a10)
                            : AppColors.error.withAlpha(AppAlpha.a10),
                        borderRadius: BorderRadius.circular(AppRadius.r2),
                      ),
                      child: Text(
                        s['status']!,
                        style: tt.labelMedium!.copyWith(color: s['status'] == 'Entregada'
                              ? AppColors.primary
                              : AppColors.error),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static const _submissions = [
    {
      'title': 'Taller 1 — Árboles',
      'date': 'Entregado hace 5 días',
      'status': 'Entregada'
    },
    {
      'title': 'Taller 2 — Grafos',
      'date': 'Venció hace 2 días',
      'status': 'Pendiente'
    },
    {
      'title': 'Parcial 1',
      'date': 'Entregado hace 2 semanas',
      'status': 'Entregada'
    },
  ];
}

class _StudentStat extends StatelessWidget {
  final String label;
  final String value;
  const _StudentStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r4),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: tt.headlineLarge!.copyWith(color: AppColors.textPrimary),
            ),
            Text(label,
                style: tt.labelMedium!.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
