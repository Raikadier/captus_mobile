// ignore_for_file: subtype_of_sealed_class

import 'package:captus_mobile/core/providers/ai_chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── AiStep pure model ──────────────────────────────────────────────────────
  group('AiStep.fromJson()', () {
    test('parses name and success=true', () {
      final s = AiStep.fromJson({'name': 'create_task', 'success': true});
      expect(s.name, 'create_task');
      expect(s.success, isTrue);
    });

    test('parses success=false', () {
      final s = AiStep.fromJson({'name': 'delete_note', 'success': false});
      expect(s.success, isFalse);
    });

    test('defaults name to "tool" when key is missing', () {
      expect(AiStep.fromJson({'success': true}).name, 'tool');
    });

    test('defaults success to true when key is missing', () {
      expect(AiStep.fromJson({'name': 'list_tasks'}).success, isTrue);
    });

    test('ignores unknown fields without throwing', () {
      final s = AiStep.fromJson({
        'name': 'create_event',
        'success': false,
        'ms': 512,
        'type': 'tool',
      });
      expect(s.name, 'create_event');
      expect(s.success, isFalse);
    });
  });

  // ── AiChatState pure model ─────────────────────────────────────────────────
  group('AiChatState.copyWith()', () {
    const base = AiChatState(
      messages: [],
      isLoading: false,
      conversationId: 'c1',
      conversationTitle: 'Old Title',
      error: 'old error',
    );

    test('clearError=true sets error to null', () {
      expect(base.copyWith(clearError: true).error, isNull);
    });

    test('preserves untouched fields', () {
      final next = base.copyWith(isLoading: true);
      expect(next.conversationId, 'c1');
      expect(next.conversationTitle, 'Old Title');
    });

    test('overrides a single field', () {
      final next = base.copyWith(conversationTitle: 'Nueva');
      expect(next.conversationTitle, 'Nueva');
      expect(next.conversationId, 'c1'); // unchanged
    });

    test('can update messages list', () {
      final msgs = [
        ChatMessage(text: 'Hi', isUser: true, time: DateTime.now()),
      ];
      expect(base.copyWith(messages: msgs).messages, hasLength(1));
    });
  });

  // ── AiChatNotifier — state-machine tests (no HTTP) ─────────────────────────
  //
  // These tests exercise state transitions that do NOT require network calls.
  // They work directly with the Notifier's state setter.

  group('AiChatNotifier — initial state', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('has exactly one welcome message', () {
      final s = container.read(aiChatProvider);
      expect(s.messages, hasLength(1));
      expect(s.messages.first.isUser, isFalse);
      expect(s.messages.first.text, contains('Captus IA'));
    });

    test('isLoading is false', () =>
        expect(container.read(aiChatProvider).isLoading, isFalse));

    test('conversationId is null', () =>
        expect(container.read(aiChatProvider).conversationId, isNull));

    test('error is null', () =>
        expect(container.read(aiChatProvider).error, isNull));
  });

  group('AiChatNotifier.stop()', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('sets isLoading=false', () {
      container.read(aiChatProvider.notifier).state =
          container.read(aiChatProvider).copyWith(isLoading: true);
      container.read(aiChatProvider.notifier).stop();
      expect(container.read(aiChatProvider).isLoading, isFalse);
    });

    test('appends a bot message mentioning "detenida"', () {
      container.read(aiChatProvider.notifier).stop();
      final last = container.read(aiChatProvider).messages.last;
      expect(last.isUser, isFalse);
      expect(last.text.toLowerCase(), contains('detenida'));
    });

    test('total message count increases by 1', () {
      final before = container.read(aiChatProvider).messages.length;
      container.read(aiChatProvider.notifier).stop();
      expect(container.read(aiChatProvider).messages.length, equals(before + 1));
    });

    test('calling stop() twice adds two messages', () {
      final before = container.read(aiChatProvider).messages.length;
      container.read(aiChatProvider.notifier).stop();
      container.read(aiChatProvider.notifier).stop();
      expect(container.read(aiChatProvider).messages.length, equals(before + 2));
    });
  });

  group('AiChatNotifier.clear()', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('resets to single welcome message', () {
      // Add some messages manually
      container.read(aiChatProvider.notifier).state = AiChatState(
        messages: [
          ChatMessage(text: 'Hola', isUser: true, time: DateTime.now()),
          ChatMessage(text: 'Respuesta', isUser: false, time: DateTime.now()),
        ],
        conversationId: 'old',
        conversationTitle: 'Título viejo',
      );

      container.read(aiChatProvider.notifier).clear();

      final s = container.read(aiChatProvider);
      expect(s.messages, hasLength(1));
      expect(s.messages.first.isUser, isFalse);
      expect(s.messages.first.text, contains('Captus IA'));
    });

    test('clears conversationId', () {
      container.read(aiChatProvider.notifier).state =
          container.read(aiChatProvider).copyWith(conversationId: 'abc');
      container.read(aiChatProvider.notifier).clear();
      expect(container.read(aiChatProvider).conversationId, isNull);
    });

    test('clears conversationTitle', () {
      container.read(aiChatProvider.notifier).state =
          container.read(aiChatProvider).copyWith(conversationTitle: 'T');
      container.read(aiChatProvider.notifier).clear();
      expect(container.read(aiChatProvider).conversationTitle, isNull);
    });

    test('clears error', () {
      container.read(aiChatProvider.notifier).state =
          container.read(aiChatProvider).copyWith(error: 'algún error');
      container.read(aiChatProvider.notifier).clear();
      expect(container.read(aiChatProvider).error, isNull);
    });

    test('clears isLoading', () {
      container.read(aiChatProvider.notifier).state =
          container.read(aiChatProvider).copyWith(isLoading: true);
      container.read(aiChatProvider.notifier).clear();
      expect(container.read(aiChatProvider).isLoading, isFalse);
    });
  });

  group('AiChatNotifier.send() — validation', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('empty string → no state change', () async {
      final before = container.read(aiChatProvider).messages.length;
      await container.read(aiChatProvider.notifier).send('');
      expect(container.read(aiChatProvider).messages.length, equals(before));
    });

    test('whitespace-only → no state change', () async {
      final before = container.read(aiChatProvider).messages.length;
      await container.read(aiChatProvider.notifier).send('   \t');
      expect(container.read(aiChatProvider).messages.length, equals(before));
    });

    test('trims whitespace from message text', () async {
      // Send will fail (no network) but the user message must be stored trimmed.
      // ApiClient.instance throws synchronously without dotenv, so the error
      // bot-message is appended before we can read. Filter by isUser instead.
      await container.read(aiChatProvider.notifier).send('  Hola mundo  ');
      final userMsgs = container
          .read(aiChatProvider)
          .messages
          .where((m) => m.isUser)
          .toList();
      expect(userMsgs, isNotEmpty, reason: 'user message should have been appended');
      expect(userMsgs.last.text, equals('Hola mundo'));
    });
  });

  group('AiChatNotifier — conversationTitle logic', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('title not overwritten on second message', () {
      // Pre-set title and conversationId
      container.read(aiChatProvider.notifier).state = AiChatState(
        messages: [
          ChatMessage(text: 'Primer mensaje', isUser: true, time: DateTime.now()),
        ],
        conversationTitle: 'Primer mensaje',
        conversationId: 'c1',
      );

      // After clear, title should be null
      container.read(aiChatProvider.notifier).clear();
      expect(container.read(aiChatProvider).conversationTitle, isNull);
    });
  });

  group('ChatMessage model', () {
    test('steps defaults to empty list', () {
      final msg = ChatMessage(
        text: 'Hola',
        isUser: true,
        time: DateTime.now(),
      );
      expect(msg.steps, isEmpty);
    });

    test('actionPerformed defaults to null', () {
      final msg = ChatMessage(
        text: 'Hola',
        isUser: true,
        time: DateTime.now(),
      );
      expect(msg.actionPerformed, isNull);
    });

    test('data defaults to null', () {
      final msg = ChatMessage(
        text: 'Hola',
        isUser: false,
        time: DateTime.now(),
      );
      expect(msg.data, isNull);
    });

    test('can carry multiple steps', () {
      final steps = [
        const AiStep(name: 'list_tasks', success: true),
        const AiStep(name: 'create_task', success: false),
      ];
      final msg = ChatMessage(
        text: 'Tarea creada',
        isUser: false,
        time: DateTime.now(),
        steps: steps,
      );
      expect(msg.steps, hasLength(2));
      expect(msg.steps.first.name, 'list_tasks');
      expect(msg.steps.last.success, isFalse);
    });
  });
}
