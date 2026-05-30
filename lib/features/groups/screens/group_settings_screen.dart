import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../models/group.dart';

class GroupSettingsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupSettingsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupSettingsScreen> createState() =>
      _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends ConsumerState<GroupSettingsScreen> {
  GroupModel? _group;
  late TextEditingController _nameController;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  void _initGroup(List<GroupModel> groups) {
    if (_group != null) return; // already initialized
    try {
      _group =
          groups.firstWhere((g) => g.id == widget.groupId);
    } catch (_) {
      _group = null;
    }
    _nameController.text = _group?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _confirmArchive() {
    showDialog(
      context: context,
      builder: (_) {
            return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r7)),
          title: Text(
            'Archivar grupo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Text(
            'El grupo quedará archivado y no aparecerá en tu lista activa.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/groups');
              },
              child: Text('Archivar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warning)),
            ),
          ],
        );
      },
    );
  }

  void _confirmLeave() {
    showDialog(
      context: context,
      builder: (_) {
            return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r7)),
          title: Text(
            'Salir del grupo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Text(
            '¿Seguro que deseas salir de "${_group?.name ?? 'este grupo'}"?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/groups');
              },
              child: Text('Salir',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  void _regenerateCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código regenerado'),
        backgroundColor: AppColors.surface2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(myGroupsProvider);
    groupsAsync.whenData(_initGroup);

    final group = _group;
    if (group == null && groupsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (group == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text('Grupo no encontrado',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Configuración del grupo',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Guardado'),
                  backgroundColor: AppColors.surface2,
                ),
              );
            },
            child: Text(
              'Guardar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s4),
        children: [
          _sectionHeader(context, 'Nombre del grupo'),
          const SizedBox(height: AppSpacing.s2),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Nombre del grupo',
            ),
          ),
          const SizedBox(height: AppSpacing.s7),
          _sectionHeader(context, 'Miembros'),
          const SizedBox(height: AppSpacing.s2),
          ...group.members.map((member) =>
              _MemberTile(member: member)),
          const SizedBox(height: AppSpacing.s7),
          _sectionHeader(context, 'Código de invitación'),
          const SizedBox(height: AppSpacing.s2),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r6),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s4, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(AppAlpha.a10),
                    borderRadius: BorderRadius.circular(AppRadius.r4),
                    border: Border.all(
                        color: AppColors.primary.withAlpha(AppAlpha.a30)),
                  ),
                  child: Text(
                    group.inviteCode,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                IconButton(
                  icon: const Icon(Icons.copy,
                      color: AppColors.textSecondary, size: 20),
                  tooltip: 'Copiar',
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: group.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Código copiado'),
                        backgroundColor: AppColors.surface2,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh,
                      color: AppColors.textSecondary, size: 20),
                  tooltip: 'Regenerar',
                  onPressed: _regenerateCode,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s7),
          _sectionHeader(context, 'Notificaciones'),
          const SizedBox(height: AppSpacing.s2),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r5),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.s2 + 2),
                Expanded(
                  child: Text(
                    'Notificaciones del grupo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (v) =>
                      setState(() => _notificationsEnabled = v),
                  activeColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surface2,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          OutlinedButton.icon(
            onPressed: _confirmArchive,
            icon: const Icon(Icons.archive_outlined,
                size: 18, color: AppColors.warning),
            label: Text(
              'Archivar grupo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.warning),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: AppColors.warning.withAlpha(AppAlpha.a50)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r5)),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          ElevatedButton.icon(
            onPressed: _confirmLeave,
            icon: const Icon(Icons.exit_to_app, size: 18),
            label: Text(
              'Salir del grupo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r5)),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.textDisabled,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _MemberTile extends StatefulWidget {
  final GroupMember member;

  const _MemberTile({required this.member});

  @override
  State<_MemberTile> createState() => _MemberTileState();
}

class _MemberTileState extends State<_MemberTile> {
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.member.isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s2),
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.courseColor(
                widget.member.id.hashCode),
            child: Text(
              widget.member.name[0],
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s2 + 2),
          Expanded(
            child: Text(
              widget.member.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textDisabled, size: 18),
            color: AppColors.surface2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r5)),
            onSelected: (value) {
              if (value == 'promote') {
                setState(() => _isAdmin = !_isAdmin);
              } else if (value == 'remove') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.member.name} eliminado',
                    ),
                    backgroundColor: AppColors.surface2,
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'promote',
                child: Row(
                  children: [
                    Icon(
                      _isAdmin
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Text(
                      _isAdmin
                          ? 'Quitar admin'
                          : 'Hacer admin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(Icons.person_remove,
                        size: 16, color: AppColors.error),
                    const SizedBox(width: AppSpacing.s2),
                    Text(
                      'Eliminar',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(AppAlpha.a10),
                borderRadius: BorderRadius.circular(AppRadius.r2),
              ),
              child: Text(
                'Admin',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
