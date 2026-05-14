import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/group.dart';

class GroupSettingsScreen extends StatefulWidget {
  final String groupId;

  const GroupSettingsScreen({super.key, required this.groupId});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late GroupModel _group;
  late TextEditingController _nameController;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _group = GroupModel.mockList.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => GroupModel.mockList.first,
    );
    _nameController = TextEditingController(text: _group.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _confirmArchive() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Archivar grupo',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'El grupo quedará archivado y no aparecerá en tu lista activa.',
          style: GoogleFonts.inter(
              fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style:
                    GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/groups');
            },
            child: Text('Archivar',
                style: GoogleFonts.inter(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  void _confirmLeave() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Salir del grupo',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Seguro que deseas salir de "${_group.name}"?',
          style: GoogleFonts.inter(
              fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style:
                    GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/groups');
            },
            child: Text('Salir',
                style: GoogleFonts.inter(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _regenerateCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código regenerado',
            style: GoogleFonts.inter(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Configuración del grupo',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Guardado',
                      style: GoogleFonts.inter(
                          color: AppColors.textPrimary)),
                  backgroundColor: AppColors.surface2,
                ),
              );
            },
            child: Text(
              'Guardar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Nombre del grupo'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: GoogleFonts.inter(
                fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Nombre del grupo',
              hintStyle: GoogleFonts.inter(
                  fontSize: 15, color: AppColors.textDisabled),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 28),
          _sectionHeader('Miembros'),
          const SizedBox(height: 8),
          ..._group.members.map((member) =>
              _MemberTile(member: member)),
          const SizedBox(height: 28),
          _sectionHeader('Código de invitación'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(AppAlpha.a10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primary.withAlpha(AppAlpha.a30)),
                  ),
                  child: Text(
                    _group.inviteCode,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.copy,
                      color: AppColors.textSecondary, size: 20),
                  tooltip: 'Copiar',
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: _group.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Código copiado',
                            style: GoogleFonts.inter(
                                color: AppColors.textPrimary)),
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
          const SizedBox(height: 28),
          _sectionHeader('Notificaciones'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Notificaciones del grupo',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
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
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: _confirmArchive,
            icon: const Icon(Icons.archive_outlined,
                size: 18, color: AppColors.warning),
            label: Text(
              'Archivar grupo',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: AppColors.warning.withAlpha(AppAlpha.a50)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _confirmLeave,
            icon: const Icon(Icons.exit_to_app, size: 18),
            label: Text(
              'Salir del grupo',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.courseColor(
                widget.member.id.hashCode),
            child: Text(
              widget.member.name[0],
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.member.name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textDisabled, size: 18),
            color: AppColors.surface2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'promote') {
                setState(() => _isAdmin = !_isAdmin);
              } else if (value == 'remove') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.member.name} eliminado',
                      style: GoogleFonts.inter(
                          color: AppColors.textPrimary),
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
                    const SizedBox(width: 8),
                    Text(
                      _isAdmin
                          ? 'Quitar admin'
                          : 'Hacer admin',
                      style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 13),
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
                    const SizedBox(width: 8),
                    Text(
                      'Eliminar',
                      style: GoogleFonts.inter(
                          color: AppColors.error,
                          fontSize: 13),
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
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Admin',
                style: GoogleFonts.inter(
                  fontSize: 10,
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
