import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/api_client.dart';
import '../../../shared/widgets/captus_dialog.dart';
import '../../../shared/widgets/captus_pressable.dart';

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
      final res =
          await ApiClient.instance.get('/projects/${widget.projectId}');
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
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
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
        '/project-comments/project/${widget.projectId}',
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
    final ok = await CaptusDialog.confirm(
      context: context,
      title: 'Eliminar proyecto',
      message:
          'Esta acción eliminará el proyecto permanentemente. ¿Continuar?',
      confirmLabel: 'Eliminar',
      isDangerous: true,
    );
    if (!ok) return;
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
    final descCtrl =
        TextEditingController(text: _project!['description'] as String? ?? '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r8)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.s6,
            right: AppSpacing.s6,
            top: AppSpacing.s5,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.s6,
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
                const SizedBox(height: AppSpacing.s5),
                Text(
                  'Editar proyecto',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  'Título *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s1),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Nombre del proyecto',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  'Descripción (opcional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s1),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: '¿De qué trata el proyecto?',
                  ),
                ),
                const SizedBox(height: AppSpacing.s5),
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
                      'Guardar',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;
    try {
      await ApiClient.instance.put('/projects/${widget.projectId}', data: {
        'title': titleCtrl.text.trim(),
        if (descCtrl.text.trim().isNotEmpty)
          'description': descCtrl.text.trim(),
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
      restorationId: 'project_detail_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _project?['title'] as String? ?? 'Proyecto',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          if (_isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: _showEditDialog,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Eliminar',
              onPressed: _deleteProject,
            ),
          ],
          const SizedBox(width: AppSpacing.s2),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
          tabs: const [
            Tab(text: 'Miembros'),
            Tab(text: 'Comentarios'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? _buildError()
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

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: AppSpacing.s3),
          Text(
            'Error al cargar el proyecto',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s4),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _load,
            child: Text(
              'Reintentar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textOnPrimary),
            ),
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
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s4, AppSpacing.s3, AppSpacing.s4, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
                ),
                onPressed: onManage,
                icon: const Icon(Icons.manage_accounts_outlined,
                    color: AppColors.primary),
                label: Text(
                  'Gestionar miembros',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ),
        Expanded(
          child: members.isEmpty
              ? Center(
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      Text(
                        'Gestiona miembros con el botón de arriba',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  itemCount: members.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.s2),
                  itemBuilder: (_, i) {
                    final m = members[i] as Map<String, dynamic>;
                    final user = m['user'] as Map<String, dynamic>? ?? m;
                    final role = m['role'] as String? ?? 'member';
                    final isOwnerRole = role == 'owner';
                    final name =
                        user['name'] as String? ?? user['email'] as String? ?? '';
                    final email = user['email'] as String? ?? '';
                    final avatarUrl = user['avatar_url'] as String?;
                    final initial = name.isNotEmpty
                        ? name[0].toUpperCase()
                        : 'U';

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.s3),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.r6),
                        border: Border.all(
                            color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                AppColors.primary.withAlpha(AppAlpha.a10),
                            backgroundImage: avatarUrl != null &&
                                    avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? Text(
                                    initial,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
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
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                                if (email.isNotEmpty)
                                  Text(
                                    email,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isOwnerRole
                                  ? AppColors.primary
                                      .withAlpha(AppAlpha.a10)
                                  : AppColors.surface2,
                              borderRadius: BorderRadius.circular(AppRadius.r8),
                            ),
                            child: Text(
                              _roleLabel(role),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: isOwnerRole
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
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
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 56,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      Text(
                        'Sin comentarios aún',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      Text(
                        'Sé el primero en comentar',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.s4),
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
                    final authorName = author['name'] as String? ??
                        author['email'] as String? ??
                        'Usuario';
                    final initial = authorName.isNotEmpty
                        ? authorName[0].toUpperCase()
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary
                                    .withAlpha(AppAlpha.a10),
                                child: Text(
                                  initial,
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s2),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authorName,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    if (c['created_at'] != null)
                                      Text(
                                        _formatDate(
                                            c['created_at'] as String),
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: AppColors.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                              CaptusPressable(
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
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: AppSpacing.s1),
                                    Text(
                                      '$likes',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s2 + 2),
                          Text(
                            c['content'] as String? ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // ── Comment input ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.s4, AppSpacing.s2, AppSpacing.s4, AppSpacing.s4),
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
                  decoration: const InputDecoration(
                    hintText: 'Escribe un comentario…',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              SizedBox(
                height: AppSpacing.buttonHeight,
                width: AppSpacing.buttonHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.r5),
                  ),
                  child: IconButton(
                    icon: submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: AppColors.textOnPrimary,
                            size: 18,
                          ),
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
