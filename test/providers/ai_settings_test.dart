import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/core/providers/ai_settings_provider.dart';

void main() {
  group('AiSettings defaults', () {
    const settings = AiSettings();

    test('accessTasks defaults to true', () {
      expect(settings.accessTasks, true);
    });

    test('accessCalendar defaults to true', () {
      expect(settings.accessCalendar, true);
    });

    test('accessGroups defaults to true', () {
      expect(settings.accessGroups, true);
    });

    test('voiceResponses defaults to false', () {
      expect(settings.voiceResponses, false);
    });

    test('proactiveSuggestions defaults to true', () {
      expect(settings.proactiveSuggestions, true);
    });

    test('toneIndex defaults to 1 (Amigable)', () {
      expect(settings.toneIndex, 1);
    });
  });

  group('AiSettings.copyWith', () {
    const original = AiSettings();

    test('can disable accessTasks', () {
      final updated = original.copyWith(accessTasks: false);
      expect(updated.accessTasks, false);
      expect(original.accessTasks, true); // immutable
    });

    test('can change toneIndex', () {
      final updated = original.copyWith(toneIndex: 2);
      expect(updated.toneIndex, 2);
      expect(original.toneIndex, 1); // immutable
    });

    test('preserves unmodified fields', () {
      final updated = original.copyWith(voiceResponses: true);
      expect(updated.accessTasks, original.accessTasks);
      expect(updated.accessCalendar, original.accessCalendar);
      expect(updated.toneIndex, original.toneIndex);
      expect(updated.proactiveSuggestions, original.proactiveSuggestions);
    });

    test('multiple fields update independently', () {
      final updated = original.copyWith(
        accessGroups: false,
        toneIndex: 0,
        voiceResponses: true,
      );
      expect(updated.accessGroups, false);
      expect(updated.toneIndex, 0);
      expect(updated.voiceResponses, true);
      expect(updated.accessTasks, true);
      expect(updated.accessCalendar, true);
    });
  });
}
