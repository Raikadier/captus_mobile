import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/conversations_provider.dart';
import '../../../core/providers/ai_chat_provider.dart';

class AiChatHistoryScreen extends ConsumerWidget {
  const AiChatHistoryScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConversations = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(conversationsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: asyncConversations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text('No se pudo cargar el historial',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(conversationsProvider.notifier).refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌵', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text('Sin conversaciones aún',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Inicia un chat con Captus IA',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.border),
            itemBuilder: (_, i) {
              final conv = conversations[i];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child: Text('🌵', style: TextStyle(fontSize: 20))),
                ),
                title: Text(conv.title,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                trailing: Text(_relativeDate(conv.updatedAt),
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary)),
                onTap: () async {
                  await ref
                      .read(aiChatProvider.notifier)
                      .loadConversation(conv.id);
                  if (context.mounted) {
                    context.go('/ai');
                  }
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(aiChatProvider.notifier).clear();
          context.go('/ai');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva conversación'),
      ),
    );
  }
}
