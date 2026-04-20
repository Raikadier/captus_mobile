import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

// ── Data models ───────────────────────────────────────────────────────────────

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

// ── Notifier ──────────────────────────────────────────────────────────────────

class AiChatNotifier extends Notifier<AiChatState> {
  static const _welcomeText =
      '¡Hola! Soy Captus IA. Tengo acceso a tus tareas, calendario y cursos. ¿En qué te puedo ayudar hoy?';

  @override
  AiChatState build() {
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

    // 1. Append user message immediately
    final userMsg = ChatMessage(text: text.trim(), isUser: true, time: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      // 2. Call backend
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        '/ai/chat',
        data: {
          'message': text.trim(),
          if (state.conversationId != null) 'conversationId': state.conversationId,
        },
      );

      final body = res.data!;
      final reply = (body['result'] as String?) ?? 'Sin respuesta.';
      final convId = body['conversationId']?.toString();
      final action = body['actionPerformed'] as String?;
      final toolData = body['data'] as Map<String, dynamic>?;

      final botMsg = ChatMessage(
        text: reply,
        isUser: false,
        time: DateTime.now(),
        actionPerformed: action,
        data: toolData,
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
        conversationId: convId ?? state.conversationId,
      );
    } on Exception catch (e) {
      final errMsg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        isLoading: false,
        error: errMsg,
        messages: [
          ...state.messages,
          ChatMessage(
            text: 'No pude conectar con el asistente. Intenta de nuevo.',
            isUser: false,
            time: DateTime.now(),
          ),
        ],
      );
    }
  }

  void clear() {
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
