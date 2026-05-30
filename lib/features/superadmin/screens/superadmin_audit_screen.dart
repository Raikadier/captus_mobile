import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/superadmin_service.dart';
import '../../../core/constants/app_spacing.dart';

class SuperAdminAuditScreen extends StatefulWidget {
  const SuperAdminAuditScreen({super.key});

  @override
  State<SuperAdminAuditScreen> createState() => _SuperAdminAuditScreenState();
}

class _SuperAdminAuditScreenState extends State<SuperAdminAuditScreen> {
  final _svc = SuperAdminService();

  List<dynamic> _logs = [];
  int _total = 0;
  int _page = 1;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) _page = 1;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _svc.getAuditLog(page: _page);
      if (mounted) setState(() {
        _logs = reset
            ? List<dynamic>.from(res['data'] as List)
            : [..._logs, ...List<dynamic>.from(res['data'] as List)];
        _total = res['total'] as int;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  IconData _iconFor(String action) {
    if (action.contains('DISABLE')) return Icons.block;
    if (action.contains('ENABLE')) return Icons.check_circle_outline;
    if (action.contains('ROLE')) return Icons.swap_horiz;
    if (action.contains('REMOVE')) return Icons.person_remove_outlined;
    if (action.contains('UPDATE')) return Icons.edit_outlined;
    return Icons.history;
  }

  Color _colorFor(String action) {
    if (action.contains('DISABLE') || action.contains('REMOVE')) return AppColors.error;
    if (action.contains('ENABLE')) return AppColors.success;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      restorationId: 'super_admin_audit_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Auditoría'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
              onPressed: () => _load(reset: true)),
        ],
      ),
      body: _loading && _logs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!),
                  ElevatedButton(
                      onPressed: () => _load(reset: true),
                      child: const Text('Reintentar')),
                ]))
              : RefreshIndicator(
                  onRefresh: () => _load(reset: true),
                  child: ListView.builder(
                    itemCount: _logs.length + (_logs.length < _total ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _logs.length) {
                        return Center(
                          child: TextButton(
                            onPressed: () { _page++; _load(); },
                            child: const Text('Cargar más'),
                          ),
                        );
                      }
                      final log = _logs[i] as Map<String, dynamic>;
                      final actor = (log['actor'] as Map?)?['name'] ??
                          (log['actor'] as Map?)?['email'] ?? 'Desconocido';
                      final action = log['action'] as String? ?? '';
                      final date = log['created_at'] as String? ?? '';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _colorFor(action).withAlpha(AppAlpha.a12),
                          child: Icon(_iconFor(action),
                              color: _colorFor(action), size: 20),
                        ),
                        title: Text(action,
                            style: tt.titleSmall),
                        subtitle: Text(
                          '$actor · ${date.length > 10 ? date.substring(0, 10) : date}',
                          style: tt.labelMedium,
                        ),
                        onTap: () => _showPayload(log),
                      );
                    },
                  ),
                ),
    );
  }

  void _showPayload(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(log['action'] as String? ?? ''),
        content: SingleChildScrollView(
          child: Text(
            (log['payload'] ?? {}).toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar')),
        ],
      ),
    );
  }
}
