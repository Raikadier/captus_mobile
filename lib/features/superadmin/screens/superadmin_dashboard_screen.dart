import 'package:flutter/material.dart';
import '../services/superadmin_service.dart';

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
    setState(() { _loading = true; _error = null; });
    try {
      final stats = await _svc.getPlatformStats();
      setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Plataforma'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: _load, child: const Text('Reintentar')),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(padding: const EdgeInsets.all(16), children: [
                    _SectionTitle('Instituciones'),
                    _KpiRow([
                      _Kpi('Total',   '${_stats!['institutions']['total'] ?? 0}',   Icons.business),
                      _Kpi('Activas', '${_stats!['institutions']['active'] ?? 0}',  Icons.check_circle_outline),
                      _Kpi('Inactivas',
                          '${(_stats!['institutions']['total'] ?? 0) - (_stats!['institutions']['active'] ?? 0)}',
                          Icons.block_outlined),
                    ]),
                    const SizedBox(height: 24),
                    _SectionTitle('Usuarios'),
                    _KpiRow([
                      _Kpi('Total',    '${_stats!['users']['total'] ?? 0}',       Icons.people),
                      _Kpi('Admins',   '${(_stats!['users']['byRole'] ?? {})['admin'] ?? 0}',   Icons.admin_panel_settings_outlined),
                      _Kpi('Docentes', '${(_stats!['users']['byRole'] ?? {})['teacher'] ?? 0}', Icons.school_outlined),
                      _Kpi('Alumnos',  '${(_stats!['users']['byRole'] ?? {})['student'] ?? 0}', Icons.person_outline),
                    ]),
                    const SizedBox(height: 24),
                    _SectionTitle('Actividad'),
                    _KpiRow([
                      _Kpi('Cursos',         '${_stats!['courses'] ?? 0}',     Icons.menu_book_outlined),
                      _Kpi('Matrículas',     '${_stats!['enrollments'] ?? 0}', Icons.how_to_reg_outlined),
                    ]),
                  ]),
                ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );
}

class _KpiRow extends StatelessWidget {
  final List<_Kpi> kpis;
  const _KpiRow(this.kpis);
  @override
  Widget build(BuildContext context) => Row(
        children: kpis
            .map((k) => Expanded(child: _KpiCard(k)))
            .toList(),
      );
}

class _Kpi {
  final String label;
  final String value;
  final IconData icon;
  const _Kpi(this.label, this.value, this.icon);
}

class _KpiCard extends StatelessWidget {
  final _Kpi kpi;
  const _KpiCard(this.kpi);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(kpi.icon, color: cs.primary, size: 28),
          const SizedBox(height: 8),
          Text(kpi.value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(kpi.label,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
