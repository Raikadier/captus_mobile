import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_client.dart';
import '../../../shared/widgets/captus_fab.dart';
import '../../../shared/widgets/cactus_refresh.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';

const _roleOptions = ['owner', 'admin', 'member'];
const _roleLabels = {
  'owner': 'Propietario',
  'admin': 'Admin',
  'member': 'Miembro',
};

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
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _showAddMemberSheet() async {
    final emailCtrl = TextEditingController();
    String selectedRole = 'member';
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r8)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.s6,
            right: AppSpacing.s6,
            top: AppSpacing.s5,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.r1),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  'Agregar miembro',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  'Email del usuario *',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.s1),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'correo@ejemplo.com',
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  'Rol',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.s1),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  items: _roleOptions
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(_roleLabels[r] ?? r),
                          ))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedRole = v!),
                ),
                const SizedBox(height: AppSpacing.s1),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.r5),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(ctx, true);
                      }
                    },
                    child: Text(
                      'Agregar',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: AppColors.textOnPrimary),
                    ),
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
    String currentRole = member['role'] as String? ?? 'member';
    final user = member['user'] as Map<String, dynamic>? ?? member;

    final newRole = await showDialog<String>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r7)),
          title: Text(
            'Cambiar rol',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          content: DropdownButtonFormField<String>(
            value: currentRole,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: user['name'] ?? user['email'] ?? '',
              labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r4),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r4),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
            ),
            items: _roleOptions
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(_roleLabels[r] ?? r),
                    ))
                .toList(),
            onChanged: (v) => setSt(() => currentRole = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx, currentRole),
              child: Text(
                'Cambiar',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textOnPrimary),
              ),
            ),
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
    final name =
        user['name'] as String? ?? user['email'] as String? ?? 'este usuario';
    final memberId = member['id'] as String?;
    if (memberId == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r7)),
        title: Text(
          'Remover miembro',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(
          '¿Remover a $name del proyecto?',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Remover',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textOnPrimary),
            ),
          ),
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
        elevation: 0,
        title: Text(
          'Miembros del proyecto',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: const [SizedBox(width: AppSpacing.s2)],
      ),
      floatingActionButton: CaptusFab(
        onPressed: _showAddMemberSheet,
        icon: Icons.person_add_rounded,
        tooltip: 'Agregar miembro',
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? _buildError()
              : _members.isEmpty
                  ? _buildEmpty()
                  : CactusRefresh(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _members.length,
                        itemBuilder: (_, i) {
                          final m = _members[i] as Map<String, dynamic>;
                          final user =
                              m['user'] as Map<String, dynamic>? ?? m;
                          final role = m['role'] as String? ?? 'member';
                          final isOwner = role == 'owner';
                          final name = user['name'] as String? ??
                              user['email'] as String? ??
                              '';
                          final email = user['email'] as String? ?? '';
                          final avatarUrl =
                              user['avatar_url'] as String?;
                          final initial = name.isNotEmpty
                              ? name[0].toUpperCase()
                              : 'U';

                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                            padding: const EdgeInsets.all(AppSpacing.s4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.r6),
                              border: Border.all(
                                  color: AppColors.border, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primary
                                      .withAlpha(AppAlpha.a10),
                                  backgroundImage: avatarUrl != null &&
                                          avatarUrl.isNotEmpty
                                      ? NetworkImage(avatarUrl)
                                      : null,
                                  child: avatarUrl == null ||
                                          avatarUrl.isEmpty
                                      ? Text(
                                          initial,
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primary),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.s3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      if (email.isNotEmpty)
                                        Text(
                                          email,
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                    ],
                                  ),
                                ),
                                if (isOwner)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withAlpha(AppAlpha.a10),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.r8),
                                    ),
                                    child: Text(
                                      'Propietario',
                                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.primary),
                                    ),
                                  )
                                else
                                  PopupMenuButton<String>(
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
                                        child: Row(
                                          children: [
                                            const Icon(Icons
                                                .swap_horiz_rounded),
                                            const SizedBox(width: AppSpacing.s3),
                                            Text('Cambiar rol'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons
                                                  .person_remove_outlined,
                                              color: AppColors.error,
                                            ),
                                            const SizedBox(width: AppSpacing.s3),
                                            Text(
                                              'Remover',
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.error),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        },
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
            'Error al cargar miembros',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.group_outlined,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            'Sin miembros',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            'Agrega miembros con el botón +',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
