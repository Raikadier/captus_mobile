import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/cactus_refresh.dart';
import '../services/admin_service.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../shared/widgets/captus_pressable.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends ConsumerState<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _institution;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        AdminService.instance.getStats(),
        AdminService.instance.getInstitution(),
      ]);
      if (mounted) {
        setState(() {
          _stats = results[0];
          _institution = results[1];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error cargando panel';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withAlpha(AppAlpha.a15),
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : 'A',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.s2 + 2),
            Text(
              'Admin',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textPrimary),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: AppSpacing.s2),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? _buildError()
              : CactusRefresh(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.s4),
                    children: [
                      // Institution name + subtitle
                      Text(
                        _institution?['name'] as String? ?? 'Mi Institución',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        'Panel de administración',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.s5),

                      // Stats grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.8,
                        children: [
                          _StatCard(
                            icon: Icons.people_rounded,
                            color: AppColors.info,
                            label: 'Estudiantes',
                            value: '${_stats?['students'] ?? 0}',
                          ),
                          _StatCard(
                            icon: Icons.school_rounded,
                            color: AppColors.accentPurple,
                            label: 'Docentes',
                            value: '${_stats?['teachers'] ?? 0}',
                          ),
                          _StatCard(
                            icon: Icons.book_rounded,
                            color: AppColors.primary,
                            label: 'Cursos',
                            value: '${_stats?['courses'] ?? 0}',
                          ),
                          _StatCard(
                            icon: Icons.trending_up_rounded,
                            color: AppColors.warning,
                            label: 'Matrículas',
                            value: '${_stats?['enrollments'] ?? 0}',
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.s6),

                      // Section header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Text(
                          'ACCIONES RÁPIDAS',
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(color: AppColors.textSecondary),
                        ),
                      ),

                      _QuickAction(
                        icon: Icons.person_add_rounded,
                        label: 'Invitar usuario',
                        onTap: () => context.go('/admin/users'),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      _QuickAction(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Crear curso',
                        onTap: () => context.go('/admin/courses'),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      _QuickAction(
                        icon: Icons.business_rounded,
                        label: 'Editar institución',
                        onTap: () => context.push('/admin/institution'),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      _QuickAction(
                        icon: Icons.grading_rounded,
                        label: 'Escalas de calificación',
                        onTap: () => context.go('/admin/grading-scales'),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      _QuickAction(
                        icon: Icons.date_range_rounded,
                        label: 'Períodos académicos',
                        onTap: () => context.go('/admin/periods'),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: AppSpacing.s3),
          Text(
            'Error al cargar el panel',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.s4),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _load,
            child: Text(
              'Reintentar',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r6),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(AppAlpha.a10),
              borderRadius: BorderRadius.circular(AppRadius.r5),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.s2 + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CaptusPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r6),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(AppAlpha.a10),
                borderRadius: BorderRadius.circular(AppRadius.r5),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppColors.textPrimary),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
