import 'package:flutter/material.dart';
import '../services/superadmin_service.dart';

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
      setState(() {
        _logs = reset
            ? List<dynamic>.from(res['data'] as List)
            : [..._logs, ...List<dynamic>.from(res['data'] as List)];
        _total = res['total'] as int;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
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

  Color _colorFor(String action, ColorScheme cs) {
    if (action.contains('DISABLE') || action.contains('REMOVE')) return cs.error;
    if (action.contains('ENABLE')) return Colors.green;
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditoría'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
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
                          backgroundColor: _colorFor(action, cs).withAlpha(30),
                          child: Icon(_iconFor(action),
                              color: _colorFor(action, cs), size: 20),
                        ),
                        title: Text(action,
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(
                          '$actor · ${date.length > 10 ? date.substring(0, 10) : date}',
                          style: const TextStyle(fontSize: 11),
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
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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
