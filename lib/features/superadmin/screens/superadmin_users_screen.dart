import 'package:flutter/material.dart';
import '../services/superadmin_service.dart';

const _roles = ['student', 'teacher', 'admin', 'superadmin'];

class SuperAdminUsersScreen extends StatefulWidget {
  const SuperAdminUsersScreen({super.key});

  @override
  State<SuperAdminUsersScreen> createState() => _SuperAdminUsersScreenState();
}

class _SuperAdminUsersScreenState extends State<SuperAdminUsersScreen> {
  final _svc = SuperAdminService();
  final _searchCtrl = TextEditingController();
  String? _roleFilter;

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
      final res = await _svc.listUsers(
        page: _page,
        search: _searchCtrl.text.trim(),
        role: _roleFilter,
      );
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

  Future<void> _changeRole(Map<String, dynamic> user) async {
    String? selected = user['role'] as String?;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text('Cambiar rol de ${user['name'] ?? user['email']}'),
          content: DropdownButtonFormField<String>(
            value: selected,
            items: _roles
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setSt(() => selected = v),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Cambiar')),
          ],
        ),
      ),
    );
    if (confirmed != true || selected == null) return;
    try {
      await _svc.changeUserRole(user['id'] as String, selected!);
      _load(reset: true);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _removeFromInstitution(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover de institución'),
        content: Text(
            '¿Remover a ${user['name'] ?? user['email']} de su institución?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _svc.removeUserFromInstitution(user['id'] as String);
      _load(reset: true);
    } catch (e) {
      _showError(e.toString());
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
      appBar: AppBar(title: const Text('Usuarios Globales')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: SearchBar(
            controller: _searchCtrl,
            hintText: 'Buscar por email…',
            onSubmitted: (_) => _load(reset: true),
            trailing: [
              IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _load(reset: true)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: DropdownButtonFormField<String>(
            value: _roleFilter,
            decoration: const InputDecoration(
                labelText: 'Filtrar por rol', border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ..._roles.map(
                  (r) => DropdownMenuItem(value: r, child: Text(r))),
            ],
            onChanged: (v) {
              _roleFilter = v;
              _load(reset: true);
            },
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
                itemBuilder: (_, i) {
                  if (i == _items.length) {
                    return Center(
                      child: TextButton(
                        onPressed: () { _page++; _load(); },
                        child: const Text('Cargar más'),
                      ),
                    );
                  }
                  final user = _items[i] as Map<String, dynamic>;
                  final instName = (user['institution'] as Map?)?['name']
                      as String?;
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user['name'] as String? ??
                        user['email'] as String? ?? ''),
                    subtitle: Text(
                        '${user['role']}${instName != null ? ' · $instName' : ''}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'role') _changeRole(user);
                        if (action == 'remove') _removeFromInstitution(user);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'role',
                            child: ListTile(
                                leading: Icon(Icons.swap_horiz),
                                title: Text('Cambiar rol'))),
                        PopupMenuItem(
                            value: 'remove',
                            child: ListTile(
                                leading: Icon(Icons.person_remove_outlined),
                                title: Text('Remover de institución'))),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ]),
    );
  }
}
