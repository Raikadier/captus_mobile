import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/conversations_provider.dart';
import '../../../core/providers/ai_chat_provider.dart';

class AiChatHistoryScreen extends ConsumerStatefulWidget {
  const AiChatHistoryScreen({super.key});

  @override
  ConsumerState<AiChatHistoryScreen> createState() =>
      _AiChatHistoryScreenState();
}

class _AiChatHistoryScreenState extends ConsumerState<AiChatHistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[date.weekday - 1];
    }
    return '${date.day}/${date.month}';
  }

  Future<void> _deleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Borrar historial',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'Se eliminarán todas las conversaciones. Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Borrar todo',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(conversationsProvider.notifier).deleteAll();
      ref.read(aiChatProvider.notifier).clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo borrar el historial.')),
      );
    }
  }

  Future<void> _deleteOne(ConversationItem conv) async {
    try {
      await ref.read(conversationsProvider.notifier).delete(conv.id);
      // If this was the active conversation, clear the chat.
      final chatState = ref.read(aiChatProvider);
      if (chatState.conversationId == conv.id) {
        ref.read(aiChatProvider.notifier).clear();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la conversación.')),
      );
    }
  }

  Future<void> _loadConversation(ConversationItem conv) async {
    final ok = await ref
        .read(aiChatProvider.notifier)
        .loadConversation(conv.id, title: conv.title);
    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la conversación.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncConversations = ref.watch(conversationsProvider);
    final query = _searchQuery.toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Historial',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          asyncConversations.maybeWhen(
            data: (list) => list.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined,
                        color: AppColors.error),
                    tooltip: 'Borrar todo',
                    onPressed: _deleteAll,
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar conversaciones…',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textSecondary, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
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

          // ── Conversation list ───────────────────────────────────────────
          Expanded(
            child: asyncConversations.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text('No se pudo cargar el historial',
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () => ref
                          .read(conversationsProvider.notifier)
                          .refresh(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (all) {
                final conversations = query.isEmpty
                    ? all
                    : all
                        .where((c) =>
                            c.title.toLowerCase().contains(query))
                        .toList();

                if (all.isEmpty) {
                  return _EmptyHistoryState(
                    onNewChat: () {
                      ref.read(aiChatProvider.notifier).clear();
                      context.pop();
                    },
                  );
                }

                if (conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text('Sin resultados para "$query"',
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      ref.read(conversationsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (_, i) {
                      final conv = conversations[i];
                      return _ConversationTile(
                        conv: conv,
                        relativeDate: _relativeDate(conv.updatedAt),
                        onTap: () => _loadConversation(conv),
                        onDelete: () => _deleteOne(conv),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB — Nueva conversación ──────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        onPressed: () {
          ref.read(aiChatProvider.notifier).clear();
          context.pop();
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Nueva conversación',
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Conversation tile with swipe-to-delete ────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ConversationItem conv;
  final String relativeDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversationTile({
    required this.conv,
    required this.relativeDate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(conv.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 22),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Eliminar conversación',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: Text(
              '¿Eliminar "${conv.title}"? Esta acción no se puede deshacer.',
              style:
                  GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Eliminar',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(AppAlpha.a10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.primary, size: 18),
          ),
          title: Text(
            conv.title,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            relativeDate,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.textSecondary),
          onTap: onTap,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyHistoryState extends StatelessWidget {
  final VoidCallback onNewChat;
  const _EmptyHistoryState({required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(AppAlpha.a10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin conversaciones aún',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia un chat con Captus IA\ny tus conversaciones aparecerán aquí.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onNewChat,
              icon: const Icon(Icons.add_rounded),
              label: Text('Iniciar conversación',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
