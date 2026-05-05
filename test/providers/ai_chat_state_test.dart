import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/core/providers/ai_chat_provider.dart';

/// Pure unit tests for [AiChatState] and [ChatMessage] value objects.
/// No widgets, providers or network calls needed.
void main() {
  // ── ChatMessage ─────────────────────────────────────────────────────────────

  group('ChatMessage', () {
    final now = DateTime(2024, 6, 1, 10, 0);

    test('creates a user message correctly', () {
      final msg = ChatMessage(text: 'Hola', isUser: true, time: now);
      expect(msg.text, 'Hola');
      expect(msg.isUser, true);
      expect(msg.actionPerformed, isNull);
      expect(msg.data, isNull);
    });

    test('creates a bot message with actionPerformed', () {
      final msg = ChatMessage(
        text: 'Tarea creada exitosamente.',
        isUser: false,
        time: now,
        actionPerformed: 'create_task',
        data: {'id': 'task-1'},
      );
      expect(msg.isUser, false);
      expect(msg.actionPerformed, 'create_task');
      expect(msg.data!['id'], 'task-1');
    });
  });

  // ── AiChatState.initial (via copyWith) ────────────────────────────────────

  group('AiChatState', () {
    const emptyState = AiChatState();

    test('default state has no messages', () {
      expect(emptyState.messages, isEmpty);
    });

    test('default state is not loading', () {
      expect(emptyState.isLoading, false);
    });

    test('default state has no conversationId', () {
      expect(emptyState.conversationId, isNull);
    });

    test('default state has no error', () {
      expect(emptyState.error, isNull);
    });

    test('copyWith replaces messages', () {
      final now = DateTime.now();
      final msg = ChatMessage(text: 'Hola', isUser: true, time: now);
      final newState = emptyState.copyWith(messages: [msg]);
      expect(newState.messages, hasLength(1));
      expect(newState.messages.first.text, 'Hola');
    });

    test('copyWith sets isLoading = true', () {
      final loading = emptyState.copyWith(isLoading: true);
      expect(loading.isLoading, true);
    });

    test('copyWith sets conversationId', () {
      final withId = emptyState.copyWith(conversationId: 'conv-abc');
      expect(withId.conversationId, 'conv-abc');
    });

    test('copyWith sets error', () {
      final withError = emptyState.copyWith(error: 'Network error');
      expect(withError.error, 'Network error');
    });

    test('copyWith preserves unspecified fields', () {
      final now = DateTime.now();
      final msg = ChatMessage(text: 'Hi', isUser: true, time: now);
      final withMsg = emptyState.copyWith(
        messages: [msg],
        conversationId: 'conv-1',
      );
      final updated = withMsg.copyWith(isLoading: true);

      // Messages and conversationId should be preserved
      expect(updated.messages, hasLength(1));
      expect(updated.conversationId, 'conv-1');
      expect(updated.isLoading, true);
    });

    test('copyWith always clears error (null resets it)', () {
      // The copyWith signature uses 'error' with no ??-fallback,
      // so passing null explicitly should reset it.
      final withError = emptyState.copyWith(error: 'Some error');
      final cleared = withError.copyWith(error: null);
      expect(cleared.error, isNull);
    });

    test('appending messages builds correct sequence', () {
      final now = DateTime.now();
      final userMsg =
          ChatMessage(text: 'Dame mis tareas', isUser: true, time: now);
      final botMsg = ChatMessage(
        text: 'Tienes 3 tareas pendientes.',
        isUser: false,
        time: now.add(const Duration(seconds: 1)),
        actionPerformed: 'list_tasks',
      );

      final s1 = emptyState.copyWith(messages: [userMsg]);
      final s2 = s1.copyWith(messages: [...s1.messages, botMsg]);

      expect(s2.messages, hasLength(2));
      expect(s2.messages[0].isUser, true);
      expect(s2.messages[1].isUser, false);
      expect(s2.messages[1].actionPerformed, 'list_tasks');
    });
  });
}
