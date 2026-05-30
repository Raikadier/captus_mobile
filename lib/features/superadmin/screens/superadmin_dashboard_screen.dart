import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/superadmin_service.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState
    extends State<SuperAdminDashboardScreen> {
  final _svc = SuperAdminService();
  Map<String, dynamic>? _stats;
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
      final stats = await _svc.getPlatformStats();
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Panel de Plataforma',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: AppSpacing.s3),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        FilledButton.tonal(
                          onPressed: _load,
                          child: Text('Reintentar',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.s4),
                    children: [
                      _SectionLabel('INSTITUCIONES'),
                      _KpiRow([
                        _Kpi(
                          label: 'Total',
                          value: '${_stats!['institutions']['total'] ?? 0}',
                          icon: Icons.business_rounded,
                          color: AppColors.primary,
                        ),
                        _Kpi(
                          label: 'Activas',
                          value: '${_stats!['institutions']['active'] ?? 0}',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                        ),
                        _Kpi(
                          label: 'Inactivas',
                          value:
                              '${(_stats!['institutions']['total'] ?? 0) - (_stats!['institutions']['active'] ?? 0)}',
                          icon: Icons.block_outlined,
                          color: AppColors.error,
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.s5),
                      _SectionLabel('USUARIOS'),
                      _KpiRow([
                        _Kpi(
                          label: 'Total',
                          value: '${_stats!['users']['total'] ?? 0}',
                          icon: Icons.people_rounded,
                          color: AppColors.primary,
                        ),
                        _Kpi(
                          label: 'Admins',
                          value:
                              '${(_stats!['users']['byRole'] ?? {})['admin'] ?? 0}',
                          icon: Icons.admin_panel_settings_outlined,
                          color: AppColors.warning,
                        ),
                        _Kpi(
                          label: 'Docentes',
                          value:
                              '${(_stats!['users']['byRole'] ?? {})['teacher'] ?? 0}',
                          icon: Icons.school_outlined,
                          color: AppColors.info,
                        ),
                        _Kpi(
                          label: 'Alumnos',
                          value:
                              '${(_stats!['users']['byRole'] ?? {})['student'] ?? 0}',
                          icon: Icons.person_outline_rounded,
                          color: AppColors.success,
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.s5),
                      _SectionLabel('ACTIVIDAD'),
                      _KpiRow([
                        _Kpi(
                          label: 'Cursos',
                          value: '${_stats!['courses'] ?? 0}',
                          icon: Icons.menu_book_outlined,
                          color: AppColors.primary,
                        ),
                        _Kpi(
                          label: 'Matrículas',
                          value: '${_stats!['enrollments'] ?? 0}',
                          icon: Icons.how_to_reg_outlined,
                          color: AppColors.info,
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.s8),
                    ],
                  ),
                ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.textSecondary),
        ),
      );
}

class _KpiRow extends StatelessWidget {
  final List<_Kpi> kpis;
  const _KpiRow(this.kpis);

  @override
  Widget build(BuildContext context) => Row(
        children: kpis.map((k) => Expanded(child: _KpiCard(k))).toList(),
      );
}

class _Kpi {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _KpiCard extends StatelessWidget {
  final _Kpi kpi;
  const _KpiCard(this.kpi);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r5),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kpi.color.withAlpha(AppAlpha.a15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(kpi.icon, color: kpi.color, size: 22),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            kpi.value,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            kpi.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
