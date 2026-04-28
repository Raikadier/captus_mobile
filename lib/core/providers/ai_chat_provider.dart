import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

// Gemini 2.5 Pro puede tardar hasta 40s en razonamiento complejo.
// Este override se aplica solo a las llamadas de IA.
final _aiRequestOptions = Options(receiveTimeout: const Duration(seconds: 90));

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
        options: _aiRequestOptions,
      );

      final body = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : <String, dynamic>{};
      final reply = (body['result'] as String?) ?? 'Sin respuesta.';
      final convId = body['conversationId']?.toString();
      final action = body['actionPerformed'] as String?;
      final rawData = body['data'];
      final toolData =
          rawData is Map<String, dynamic> ? rawData : null;

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
    } catch (e) {
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

  /// Loads an existing conversation from the backend by ID.
  /// Replaces the current state with the fetched messages.
  Future<void> loadConversation(String conversationId) async {
    state = state.copyWith(isLoading: true, conversationId: conversationId);
    try {
      final res = await ApiClient.instance
          .get<List<dynamic>>('/ai/conversations/$conversationId/messages');
      final raw = res.data is List ? res.data as List<dynamic> : <dynamic>[];
      final loaded = raw.map((m) {
        final map = m as Map<String, dynamic>;
        return ChatMessage(
          text: (map['content'] as String?) ?? '',
          isUser: map['role'] == 'user',
          time: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
        );
      }).toList();

      state = AiChatState(
        messages: loaded.isEmpty
            ? [ChatMessage(text: _welcomeText, isUser: false, time: DateTime.now())]
            : loaded,
        isLoading: false,
        conversationId: conversationId,
      );
    } on Exception {
      state = state.copyWith(isLoading: false);
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
