import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_client.dart';

const _roleOptions = ['owner', 'admin', 'member'];
const _roleLabels = {'owner': 'Propietario', 'admin': 'Admin', 'member': 'Miembro'};

class ProjectMembersScreen extends StatefulWidget {
  final String projectId;

  const ProjectMembersScreen({super.key, required this.projectId});

  @override
  State<ProjectMembersScreen> createState() => _ProjectMembersScreenState();
}

class _ProjectMembersScreenState extends State<ProjectMembersScreen> {
  List<dynamic> _members = [];
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
      final res = await ApiClient.instance
          .get('/project-members/project/${widget.projectId}');
      final data = res.data;
      if (mounted) {
        setState(() {
          if (data is List) {
            _members = data;
          } else if (data is Map && data['data'] is List) {
            _members = data['data'] as List;
          } else {
            _members = [];
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _showAddMemberDialog() async {
    final emailCtrl = TextEditingController();
    String selectedRole = 'member';
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agregar miembro',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email del usuario *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                  ),
                  items: _roleOptions
                      .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(_roleLabels[r] ?? r)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedRole = v!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(ctx, true);
                      }
                    },
                    child: const Text('Agregar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiClient.instance.post(
        '/project-members/project/${widget.projectId}',
        data: {
          'email': emailCtrl.text.trim(),
          'role': selectedRole,
        },
      );
      _showSnack('Miembro agregado', isError: false);
      await _load();
    } catch (e) {
      _showSnack('Error al agregar miembro: $e');
    }
  }

  Future<void> _changeRole(Map<String, dynamic> member) async {
    String currentRole =
        member['role'] as String? ?? 'member';
    final user = member['user'] as Map<String, dynamic>? ?? member;

    final newRole = await showDialog<String>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title:
              Text('Cambiar rol de ${user['name'] ?? user['email'] ?? ''}'),
          content: DropdownButtonFormField<String>(
            value: currentRole,
            items: _roleOptions
                .map((r) =>
                    DropdownMenuItem(value: r, child: Text(_roleLabels[r] ?? r)))
                .toList(),
            onChanged: (v) => setSt(() => currentRole = v!),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, currentRole),
                child: const Text('Cambiar')),
          ],
        ),
      ),
    );

    if (newRole == null || !mounted) return;

    final memberId = member['id'] as String?;
    if (memberId == null) return;

    try {
      await ApiClient.instance.patch(
        '/project-members/$memberId',
        data: {'role': newRole},
      );
      await _load();
    } catch (e) {
      _showSnack('Error al cambiar rol: $e');
    }
  }

  Future<void> _removeMember(Map<String, dynamic> member) async {
    final user = member['user'] as Map<String, dynamic>? ?? member;
    final name = user['name'] as String? ?? user['email'] as String? ?? 'este usuario';
    final memberId = member['id'] as String?;
    if (memberId == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover miembro'),
        content: Text('¿Remover a $name del proyecto?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Remover')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ApiClient.instance.delete('/project-members/$memberId');
      await _load();
    } catch (e) {
      _showSnack('Error al remover miembro: $e');
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Miembros del proyecto',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberDialog,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Agregar'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _load,
                          child: const Text('Reintentar')),
                    ],
                  ),
                )
              : _members.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.group_outlined,
                              size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text('Sin miembros',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text('Agrega miembros con el botón +',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _members.length,
                        itemBuilder: (_, i) {
                          final m = _members[i] as Map<String, dynamic>;
                          final user =
                              m['user'] as Map<String, dynamic>? ?? m;
                          final role = m['role'] as String? ?? 'member';
                          final isOwner = role == 'owner';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    AppColors.primary.withAlpha(20),
                                backgroundImage: user['avatar_url'] != null &&
                                        (user['avatar_url'] as String)
                                            .isNotEmpty
                                    ? NetworkImage(
                                        user['avatar_url'] as String)
                                    : null,
                                child: user['avatar_url'] == null ||
                                        (user['avatar_url'] as String).isEmpty
                                    ? Text(
                                        ((user['name'] as String? ??
                                                    'U')[0])
                                                .toUpperCase(),
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary),
                                      )
                                    : null,
                              ),
                              title: Text(
                                user['name'] as String? ??
                                    user['email'] as String? ??
                                    '',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                              subtitle: Text(
                                user['email'] as String? ?? '',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                              trailing: isOwner
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(20),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Propietario',
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary),
                                      ),
                                    )
                                  : PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert,
                                          color: AppColors.textSecondary),
                                      onSelected: (action) {
                                        if (action == 'role') {
                                          _changeRole(m);
                                        } else if (action == 'remove') {
                                          _removeMember(m);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: 'role',
                                          child: ListTile(
                                            leading: const Icon(
                                                Icons.swap_horiz_rounded),
                                            title: Text(
                                                _roleLabels[role] ?? role),
                                            subtitle: const Text(
                                                'Cambiar rol'),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'remove',
                                          child: ListTile(
                                            leading: Icon(
                                                Icons.person_remove_outlined,
                                                color: AppColors.error),
                                            title: Text('Remover',
                                                style: TextStyle(
                                                    color: AppColors.error)),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
