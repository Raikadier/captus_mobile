import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';

final _aiReceiveOptions = Options(receiveTimeout: const Duration(seconds: 90));

class AiStep {
  final String name;
  final bool success;

  const AiStep({
    required this.name,
    required this.success,
  });

  factory AiStep.fromJson(Map<String, dynamic> json) {
    return AiStep(
      name: json['name'] as String? ?? 'tool',
      success: json['success'] as bool? ?? true,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final String? actionPerformed;
  final Map<String, dynamic>? data;
  final List<AiStep> steps;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.actionPerformed,
    this.data,
    this.steps = const [],
  });
}

class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? conversationId;
  final String? conversationTitle;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.conversationId,
    this.conversationTitle,
    this.error,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? conversationId,
    String? conversationTitle,
    String? error,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      conversationId: conversationId ?? this.conversationId,
      conversationTitle: conversationTitle ?? this.conversationTitle,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AiChatNotifier extends Notifier<AiChatState> {
  static const _welcomeText =
      '¡Hola! Soy Captus IA. Tengo acceso a tus tareas, calendario y cursos. ¿En qué te puedo ayudar hoy?';

  CancelToken _cancelToken = CancelToken();

  @override
  AiChatState build() {
    Future.microtask(_loadLatestConversation);

    return AiChatState(
      messages: [
        ChatMessage(
          text: _welcomeText,
          isUser: false,
          time: DateTime.now(),
        ),
      ],
    );
  }

  void stop() {
    _cancelToken.cancel('Usuario detuvo la respuesta');
    _cancelToken = CancelToken();

    state = state.copyWith(
      isLoading: false,
      messages: [
        ...state.messages,
        ChatMessage(
          text: '_Respuesta detenida._',
          isUser: false,
          time: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> _loadLatestConversation() async {
    try {
      final res =
          await ApiClient.instance.get<List<dynamic>>('/ai/conversations');

      final list = res.data;
      if (list == null || list.isEmpty) return;

      final latest = list.first as Map<String, dynamic>;
      final id = latest['id']?.toString();
      final title = latest['title']?.toString().trim();

      if (id == null || id.isEmpty) return;

      await loadConversation(
        id,
        title: title == null || title.isEmpty ? null : title,
      );
    } catch (_) {
      // Si falla, la conversación inicia limpia.
    }
  }

  Future<void> send(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    _cancelToken = CancelToken();

    final userMsg = ChatMessage(
      text: cleanText,
      isUser: true,
      time: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
    );

    try {
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        '/ai/chat',
        data: {
          'message': cleanText,
          if (state.conversationId != null)
            'conversationId': state.conversationId,
        },
        options: _aiReceiveOptions,
        cancelToken: _cancelToken,
      );

      final body = res.data ?? <String, dynamic>{};

      final reply = body['result'] as String? ?? 'Sin respuesta.';
      final convId = body['conversationId']?.toString();
      final action = body['actionPerformed'] as String?;

      final rawData = body['data'];
      final toolData = rawData is Map<String, dynamic> ? rawData : null;

      final rawSteps = body['steps'] as List<dynamic>? ?? [];
      final steps = rawSteps
          .whereType<Map<String, dynamic>>()
          .map(AiStep.fromJson)
          .toList();

      final botMsg = ChatMessage(
        text: reply,
        isUser: false,
        time: DateTime.now(),
        actionPerformed: action,
        data: toolData,
        steps: steps,
      );

      final newTitle = state.conversationTitle ??
          (cleanText.length > 50
              ? '${cleanText.substring(0, 50)}…'
              : cleanText);

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
        conversationId: convId ?? state.conversationId,
        conversationTitle: newTitle,
        clearError: true,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;

      state = state.copyWith(
        isLoading: false,
        error: 'No pude conectar con el asistente. Intenta de nuevo.',
        messages: [
          ...state.messages,
          ChatMessage(
            text: 'No pude conectar con el asistente. Intenta de nuevo.',
            isUser: false,
            time: DateTime.now(),
          ),
        ],
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado. Intenta de nuevo.',
        messages: [
          ...state.messages,
          ChatMessage(
            text: 'Error inesperado. Intenta de nuevo.',
            isUser: false,
            time: DateTime.now(),
          ),
        ],
      );
    }
  }

  Future<void> loadConversation(
    String conversationId, {
    String? title,
  }) async {
    state = state.copyWith(
      isLoading: true,
      conversationId: conversationId,
      conversationTitle: title,
      clearError: true,
    );

    try {
      final res = await ApiClient.instance
          .get<List<dynamic>>('/ai/conversations/$conversationId/messages');

      final raw = res.data ?? <dynamic>[];

      final loaded = raw.whereType<Map<String, dynamic>>().map((map) {
        return ChatMessage(
          text: map['content'] as String? ?? '',
          isUser: map['role'] == 'user',
          time: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
        );
      }).toList();

      state = AiChatState(
        messages: loaded.isEmpty
            ? [
                ChatMessage(
                  text: _welcomeText,
                  isUser: false,
                  time: DateTime.now(),
                ),
              ]
            : loaded,
        isLoading: false,
        conversationId: conversationId,
        conversationTitle: title,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'No se pudo cargar la conversación.',
      );
    }
  }

  void clear() {
    _cancelToken.cancel('Nueva conversación');
    _cancelToken = CancelToken();

    state = AiChatState(
      messages: [
        ChatMessage(
          text: _welcomeText,
          isUser: false,
          time: DateTime.now(),
        ),
      ],
    );
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);