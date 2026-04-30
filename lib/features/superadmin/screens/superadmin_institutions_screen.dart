import 'package:flutter/material.dart';
import '../services/superadmin_service.dart';

class SuperAdminInstitutionsScreen extends StatefulWidget {
  const SuperAdminInstitutionsScreen({super.key});

  @override
  State<SuperAdminInstitutionsScreen> createState() =>
      _SuperAdminInstitutionsScreenState();
}

class _SuperAdminInstitutionsScreenState
    extends State<SuperAdminInstitutionsScreen> {
  final _svc = SuperAdminService();
  final _searchCtrl = TextEditingController();

  List<dynamic> _items = [];
  int _total = 0;
  int _page = 1;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) _page = 1;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _svc.listInstitutions(
          page: _page, search: _searchCtrl.text.trim());
      setState(() {
        _items = reset
            ? List<dynamic>.from(res['data'] as List)
            : [..._items, ...List<dynamic>.from(res['data'] as List)];
        _total = res['total'] as int;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> inst) async {
    final isActive = inst['is_active'] as bool? ?? true;
    if (isActive) {
      // Ask for reason
      final reasonCtrl = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Deshabilitar institución'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Deshabilitarás "${inst['name']}". Escribe el motivo:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(labelText: 'Motivo'),
              maxLines: 2,
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Deshabilitar')),
          ],
        ),
      );
      if (confirmed != true || reasonCtrl.text.trim().isEmpty) return;
      try {
        await _svc.disableInstitution(inst['id'] as String,
            reasonCtrl.text.trim());
        _load(reset: true);
      } catch (e) {
        _showError(e.toString());
      }
    } else {
      try {
        await _svc.enableInstitution(inst['id'] as String);
        _load(reset: true);
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instituciones')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SearchBar(
            controller: _searchCtrl,
            hintText: 'Buscar institución…',
            onSubmitted: (_) => _load(reset: true),
            trailing: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _load(reset: true),
              ),
            ],
          ),
        ),
        if (_loading && _items.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          Expanded(
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_error!),
              ElevatedButton(
                  onPressed: () => _load(reset: true),
                  child: const Text('Reintentar')),
            ])),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: ListView.builder(
                itemCount: _items.length + (_items.length < _total ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == _items.length) {
                    return Center(
                      child: TextButton(
                        onPressed: () {
                          _page++;
                          _load();
                        },
                        child: const Text('Cargar más'),
                      ),
                    );
                  }
                  final inst = _items[i] as Map<String, dynamic>;
                  final active = inst['is_active'] as bool? ?? true;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          active ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(Icons.business,
                          color: active ? Colors.green : Colors.red),
                    ),
                    title: Text(inst['name'] as String? ?? ''),
                    subtitle: Text(
                      active ? 'Activa' : 'Deshabilitada',
                      style: TextStyle(
                          color: active ? Colors.green : Colors.red),
                    ),
                    trailing: Switch(
                      value: active,
                      onChanged: (_) => _toggleActive(inst),
                    ),
                    onTap: () => _showDetail(inst),
                  );
                },
              ),
            ),
          ),
      ]),
    );
  }

  void _showDetail(Map<String, dynamic> inst) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, ctrl) => _InstitutionDetailSheet(
          instId: inst['id'] as String,
          svc: _svc,
          scrollController: ctrl,
        ),
      ),
    );
  }
}

class _InstitutionDetailSheet extends StatefulWidget {
  final String instId;
  final SuperAdminService svc;
  final ScrollController scrollController;

  const _InstitutionDetailSheet({
    required this.instId,
    required this.svc,
    required this.scrollController,
  });

  @override
  State<_InstitutionDetailSheet> createState() =>
      _InstitutionDetailSheetState();
}

class _InstitutionDetailSheetState extends State<_InstitutionDetailSheet> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await widget.svc.getInstitution(widget.instId);
      setState(() { _detail = d; _loading = false; });
    } catch (_) {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_detail == null) return const Center(child: Text('Error cargando detalles'));

    final stats = _detail!['stats'] as Map<String, dynamic>? ?? {};
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        Text(_detail!['name'] as String? ?? '',
            style: Theme.of(context).textTheme.titleLarge),
        if (_detail!['email'] != null) ...[
          const SizedBox(height: 4),
          Text(_detail!['email'] as String),
        ],
        const Divider(height: 24),
        _StatRow('Miembros',    '${stats['members'] ?? 0}'),
        _StatRow('Cursos',      '${stats['courses'] ?? 0}'),
        _StatRow('Matrículas',  '${stats['enrollments'] ?? 0}'),
        if ((stats['byRole'] as Map?) != null) ...[
          const SizedBox(height: 8),
          _StatRow('  Admins',   '${(stats['byRole'] as Map)['admin'] ?? 0}'),
          _StatRow('  Docentes', '${(stats['byRole'] as Map)['teacher'] ?? 0}'),
          _StatRow('  Alumnos',  '${(stats['byRole'] as Map)['student'] ?? 0}'),
        ],
        if (_detail!['disabled_reason'] != null) ...[
          const Divider(height: 24),
          Text('Motivo deshabilitación:',
              style: Theme.of(context).textTheme.labelMedium),
          Text(_detail!['disabled_reason'] as String),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
