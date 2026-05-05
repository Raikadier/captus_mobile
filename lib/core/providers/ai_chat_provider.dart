import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final String? actionPerformed;
  final Map<String, dynamic>? data;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.actionPerformed,
    this.data,
  });
}

class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? conversationId;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.conversationId,
    this.error,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? conversationId,
    String? error,
  }) =>
      AiChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        conversationId: conversationId ?? this.conversationId,
        error: error,
      );
}

class AiChatNotifier extends Notifier<AiChatState> {
  static const _welcomeText =
      '¡Hola! Soy Captus IA. Tengo acceso a tus tareas, calendario y cursos. ¿En qué te puedo ayudar hoy?';

  @override
  AiChatState build() {
    final storedMessages = LocalStorageService.chatMessages;
    if (storedMessages.isNotEmpty) {
      final messages = storedMessages
          .map((m) => ChatMessage(
                text: m['text']?.toString() ?? '',
                isUser: m['isUser'] as bool? ?? false,
                time: DateTime.tryParse(m['time']?.toString() ?? '') ??
                    DateTime.now(),
                actionPerformed: m['actionPerformed']?.toString(),
                data: m['data'] as Map<String, dynamic>?,
              ))
          .toList();
      return AiChatState(messages: messages);
    }

    return AiChatState(
      messages: [
        ChatMessage(
          text: _welcomeText,
          isUser: false,
          time: DateTime.now(),
        )
      ],
    );
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg =
        ChatMessage(text: text.trim(), isUser: true, time: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    await Future.delayed(const Duration(milliseconds: 800));

    final reply = _generateMockResponse(text.trim());

    final botMsg = ChatMessage(
      text: reply,
      isUser: false,
      time: DateTime.now(),
    );

    final newMessages = [...state.messages, botMsg];
    state = state.copyWith(
      messages: newMessages,
      isLoading: false,
    );

    await LocalStorageService.clearChatMessages();
    for (final msg in newMessages) {
      await LocalStorageService.addChatMessage({
        'text': msg.text,
        'isUser': msg.isUser,
        'time': msg.time.toIso8601String(),
        'actionPerformed': msg.actionPerformed,
        'data': msg.data,
      });
    }
  }

  String _generateMockResponse(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('tarea') || lower.contains('tareas')) {
      return 'Tienes 5 tareas pendientes. Las más urgentes son:\n\n'
          '• Taller Árboles Binarios - mañana\n'
          '• Práctica Shell Scripting - en 1 día\n'
          '• Parcial Cálculo II - en 7 días';
    }

    if (lower.contains('curso') || lower.contains('cursos')) {
      return 'Estás inscrito en 4 cursos:\n\n'
          '• Estructuras de Datos - 65% completado\n'
          '• Cálculo II - 40% completado\n'
          '• Ingeniería de Software I - 80% completado\n'
          '• Sistemas Operativos - 55% completado';
    }

    if (lower.contains('calendario') || lower.contains('evento')) {
      return 'Tienes los siguientes eventos próximos:\n\n'
          '• Parcial Cálculo II - en 7 días\n'
          '• Entrega Proyecto IS - en 14 días\n'
          '• Clase Extra EDD - en 5 días';
    }

    if (lower.contains('ayuda') || lower.contains('help')) {
      return 'Puedo ayudarte con:\n\n'
          '📝 Ver tus tareas pendientes\n'
          '📚 Info de tus cursos\n'
          '📅 Ver eventos del calendario\n'
          '📊 Tu progreso académico\n'
          '❓ Responder preguntas generales';
    }

    if (lower.contains('progreso') || lower.contains('estadística')) {
      return 'Tu progreso esta semana:\n\n'
          '✅ 2 tareas completadas\n'
          '🔥 Racha: 7 días\n'
          '📚 Promedio: 72%\n\n'
          '¡Sigue así! 💪';
    }

    return 'Entendido: "$input"\n\n'
        'Como asistente local, puedo mostrarte información sobre tus tareas, '
        'cursos y calendario. ¿Qué te gustaría saber?';
  }

  Future<void> loadConversation(String conversationId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      conversationId: conversationId,
    );

    // Simular carga de datos remotos
    await Future.delayed(const Duration(milliseconds: 600));

    // Por ahora mantenemos los mensajes actuales o podríamos cargar mocks específicos.
    // Lo importante es que el estado refleje el ID de la conversación.
    state = state.copyWith(isLoading: false);
  }

  void clear() {
    LocalStorageService.clearChatMessages();
    state = AiChatState(
      messages: [
        ChatMessage(
          text: _welcomeText,
          isUser: false,
          time: DateTime.now(),
        )
      ],
    );
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
