import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class AiChatHistoryScreen extends StatelessWidget {
  const AiChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {
        'title': 'Planificación semana',
        'preview': 'Tienes 3 entregas...',
        'date': 'Hoy'
      },
      {
        'title': 'Ayuda con Cálculo',
        'preview': '¿Puedes explicarme integrales?',
        'date': 'Ayer'
      },
      {
        'title': 'Crear tareas',
        'preview': 'Entregar ensayo de historia...',
        'date': 'Lun'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(color: AppColors.border),
        itemBuilder: (_, i) {
          final chat = chats[i];
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('🌵', style: TextStyle(fontSize: 20))),
            ),
            title: Text(chat['title']!,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(chat['preview']!,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis),
            trailing: Text(chat['date']!,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary)),
            onTap: () => context.push('/ai'),
            contentPadding: EdgeInsets.zero,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ai'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva conversación'),
      ),
    );
  }
}
