import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_client.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl = TabController(length: 2, vsync: this);

  Map<String, dynamic>? _project;
  List<dynamic> _members = [];
  List<dynamic> _comments = [];
  bool _loading = true;
  String? _error;

  // Comment input
  final _commentCtrl = TextEditingController();
  bool _submittingComment = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.get('/projects/${widget.projectId}');
      final data = res.data as Map<String, dynamic>;
      final membersRaw = data['members'] as List<dynamic>? ?? [];
      final commentsRaw = data['comments'] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _project = data;
          _members = membersRaw;
          _comments = commentsRaw;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  bool get _isOwner {
    if (_project == null) return false;
    final role = _project!['userRole'] as String? ?? '';
    return role == 'owner' || role == 'admin';
  }

  Future<void> _addComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _submittingComment = true);
    try {
      await ApiClient.instance.post(
        '/projects/${widget.projectId}/comments',
        data: {'content': text},
      );
      _commentCtrl.clear();
      await _load();
    } catch (e) {
      _showSnack('Error al publicar comentario: $e');
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  Future<void> _toggleLike(String commentId) async {
    try {
      await ApiClient.instance
          .put('/comment-likes/comment/$commentId/toggle');
      await _load();
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  Future<void> _deleteProject() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: const Text(
            'Esta acción eliminará el proyecto permanentemente. ¿Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiClient.instance.delete('/projects/${widget.projectId}');
      if (mounted) context.pop();
    } catch (e) {
      _showSnack('Error al eliminar: $e');
    }
  }

  Future<void> _showEditDialog() async {
    if (_project == null) return;
    final titleCtrl =
        TextEditingController(text: _project!['title'] as String? ?? '');
    final descCtrl = TextEditingController(
        text: _project!['description'] as String? ?? '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
                'Editar proyecto',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Título *', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder()),
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
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await ApiClient.instance.put('/projects/${widget.projectId}', data: {
        'title': titleCtrl.text.trim(),
        if (descCtrl.text.trim().isNotEmpty) 'description': descCtrl.text.trim(),
      });
      await _load();
    } catch (e) {
      _showSnack('Error al guardar: $e');
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
          _project?['title'] as String? ?? 'Proyecto',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          if (_isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _showEditDialog,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteProject,
            ),
          ],
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Miembros'),
            Tab(text: 'Comentarios'),
          ],
        ),
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
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _MembersTab(
                      members: _members,
                      projectId: widget.projectId,
                      isOwner: _isOwner,
                      onManage: () => context
                          .push('/projects/${widget.projectId}/members')
                          .then((_) => _load()),
                    ),
                    _CommentsTab(
                      comments: _comments,
                      commentCtrl: _commentCtrl,
                      submitting: _submittingComment,
                      onSubmit: _addComment,
                      onLike: _toggleLike,
                    ),
                  ],
                ),
    );
  }
}

// ── Members tab ────────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final List<dynamic> members;
  final String projectId;
  final bool isOwner;
  final VoidCallback onManage;

  const _MembersTab({
    required this.members,
    required this.projectId,
    required this.isOwner,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isOwner)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onManage,
                icon: const Icon(Icons.manage_accounts_outlined,
                    color: AppColors.primary),
                label: Text('Gestionar miembros',
                    style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.group_outlined,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text('Sin miembros',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 15)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (_, i) {
                    final m = members[i] as Map<String, dynamic>;
                    final user =
                        m['user'] as Map<String, dynamic>? ?? m;
                    final role = m['role'] as String? ?? 'member';
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 4),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withAlpha(20),
                        backgroundImage:
                            user['avatar_url'] != null &&
                                    (user['avatar_url'] as String)
                                        .isNotEmpty
                                ? NetworkImage(user['avatar_url'] as String)
                                : null,
                        child: user['avatar_url'] == null ||
                                (user['avatar_url'] as String).isEmpty
                            ? Text(
                                ((user['name'] as String? ?? 'U')[0])
                                    .toUpperCase(),
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              )
                            : null,
                      ),
                      title: Text(
                        user['name'] as String? ?? user['email'] as String? ?? '',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        user['email'] as String? ?? '',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: role == 'owner'
                              ? AppColors.primary.withAlpha(20)
                              : AppColors.surface2,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _roleLabel(role),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: role == 'owner'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'owner':
        return 'Propietario';
      case 'admin':
        return 'Admin';
      default:
        return 'Miembro';
    }
  }
}

// ── Comments tab ───────────────────────────────────────────────────────────────

class _CommentsTab extends StatelessWidget {
  final List<dynamic> comments;
  final TextEditingController commentCtrl;
  final bool submitting;
  final VoidCallback onSubmit;
  final void Function(String) onLike;

  const _CommentsTab({
    required this.comments,
    required this.commentCtrl,
    required this.submitting,
    required this.onSubmit,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: comments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text('Sin comentarios aún',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Sé el primero en comentar',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (_, i) {
                    final c = comments[i] as Map<String, dynamic>;
                    final author =
                        c['author'] as Map<String, dynamic>? ??
                            c['user'] as Map<String, dynamic>? ??
                            {};
                    final likes = c['likeCount'] as int? ??
                        (c['likes'] as List?)?.length ??
                        0;
                    final liked = c['isLiked'] as bool? ?? false;
                    final commentId = c['id'] as String? ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    AppColors.primary.withAlpha(20),
                                child: Text(
                                  ((author['name'] as String? ?? 'U')[0])
                                      .toUpperCase(),
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      author['name'] as String? ??
                                          author['email'] as String? ??
                                          'Usuario',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary),
                                    ),
                                    if (c['created_at'] != null)
                                      Text(
                                        _formatDate(
                                            c['created_at'] as String),
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: commentId.isNotEmpty
                                    ? () => onLike(commentId)
                                    : null,
                                child: Row(
                                  children: [
                                    Icon(
                                      liked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 18,
                                      color: liked
                                          ? Colors.red
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$likes',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            c['content'] as String? ?? '',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.45),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // ── Comment input ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  minLines: 1,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Escribe un comentario…',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                width: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                    onPressed: submitting ? null : onSubmit,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
