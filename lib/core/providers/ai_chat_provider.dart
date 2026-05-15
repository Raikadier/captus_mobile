import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';
import 'auth_provider.dart';

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
  CancelToken _cancelToken = CancelToken();

  // ── Welcome message (role-aware) ───────────────────────────────────────────

  static String _welcomeFor(String role, String? firstName) {
    final greeting =
        firstName != null && firstName.isNotEmpty ? '¡Hola, $firstName!' : '¡Hola!';
    if (role == 'teacher') {
      return '$greeting Soy Captus IA, tu asistente docente. Puedo '
          'analizar el rendimiento de tus estudiantes, generar rúbricas, '
          'bancos de preguntas, planes de semestre y más. ¿En qué te ayudo?';
    }
    if (role == 'admin' || role == 'superadmin') {
      return '$greeting Soy Captus IA. Puedo responder preguntas sobre '
          'la plataforma y ayudarte a gestionar tu institución.';
    }
    return '$greeting Soy Captus IA. Tengo acceso a tus tareas, '
        'calendario y cursos. ¿En qué te puedo ayudar hoy?';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  AiChatState build() {
    // Watch auth so the provider re-builds (resets) automatically on:
    //  • logout / login (different user)
    //  • role change
    // This prevents chat state from bleeding between users on the same device.
    final user = ref.watch(currentUserProvider);
    final role = user?.role ?? 'student';
    final firstName = user?.name.split(' ').firstOrNull;

    // Do NOT auto-load the last conversation — each session starts fresh.
    // Users can access previous chats via the History button.
    return AiChatState(
      messages: [
        ChatMessage(
          text: _welcomeFor(role, firstName),
          isUser: false,
          time: DateTime.now(),
        ),
      ],
    );
  }

  // ── Public API ─────────────────────────────────────────────────────────────

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

      final user = ref.read(currentUserProvider);
      final role = user?.role ?? 'student';
      final firstName = user?.name.split(' ').firstOrNull;

      state = AiChatState(
        messages: loaded.isEmpty
            ? [
                ChatMessage(
                  text: _welcomeFor(role, firstName),
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

  /// Starts a new conversation, releasing the keep-alive so the provider
  /// can be disposed normally when the user navigates away.
  void clear() {
    _cancelToken.cancel('Nueva conversación');
    _cancelToken = CancelToken();

    final user = ref.read(currentUserProvider);
    final role = user?.role ?? 'student';
    final firstName = user?.name.split(' ').firstOrNull;

    state = AiChatState(
      messages: [
        ChatMessage(
          text: _welcomeFor(role, firstName),
          isUser: false,
          time: DateTime.now(),
        ),
      ],
    );
  }
}

// NotifierProvider that watches currentUserProvider in build() so it rebuilds
// (resets to fresh chat) automatically when the authenticated user changes —
// this prevents chat state from bleeding between users on the same device.
final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
