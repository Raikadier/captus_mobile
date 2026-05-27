import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/features/statistics/utils/streak_messages.dart';

void main() {
  group('getStreakMessage', () {
    test('returns a non-empty string for streak = 0', () {
      final msg = getStreakMessage(0);
      expect(msg, isNotEmpty);
    });

    test('returns a non-empty string for streak = 1 (small streak)', () {
      final msg = getStreakMessage(1);
      expect(msg, isNotEmpty);
    });

    test('returns a non-empty string for streak = 6 (small streak boundary)', () {
      expect(getStreakMessage(6), isNotEmpty);
    });

    test('returns a non-empty string for streak = 7 (medium streak)', () {
      expect(getStreakMessage(7), isNotEmpty);
    });

    test('returns a non-empty string for streak = 29 (medium streak boundary)', () {
      expect(getStreakMessage(29), isNotEmpty);
    });

    test('returns a non-empty string for streak = 30 (large streak)', () {
      expect(getStreakMessage(30), isNotEmpty);
    });

    test('returns a non-empty string for streak = 99 (large streak boundary)', () {
      expect(getStreakMessage(99), isNotEmpty);
    });

    test('returns a non-empty string for streak = 100 (legendary)', () {
      expect(getStreakMessage(100), isNotEmpty);
    });

    test('returns a non-empty string for streak = 365 (legendary)', () {
      expect(getStreakMessage(365), isNotEmpty);
    });

    // Not deterministic but the message pool is large — calling 20 times
    // should eventually produce at least 2 distinct values (pool size > 1).
    test('is random (non-deterministic) within the pool for streak = 0', () {
      final results = List.generate(30, (_) => getStreakMessage(0)).toSet();
      // The zero-day pool has 7 messages; after 30 draws we expect variety.
      expect(results.length, greaterThan(1));
    });
  });

  group('getStreakEmoji', () {
    test('streak 0 → seedling', () => expect(getStreakEmoji(0), '🌱'));
    test('streak 1 → fire', () => expect(getStreakEmoji(1), '🔥'));
    test('streak 2 → fire', () => expect(getStreakEmoji(2), '🔥'));
    test('streak 3 → muscle', () => expect(getStreakEmoji(3), '💪'));
    test('streak 6 → muscle', () => expect(getStreakEmoji(6), '💪'));
    test('streak 7 → lightning', () => expect(getStreakEmoji(7), '⚡'));
    test('streak 13 → lightning', () => expect(getStreakEmoji(13), '⚡'));
    test('streak 14 → star', () => expect(getStreakEmoji(14), '🌟'));
    test('streak 29 → star', () => expect(getStreakEmoji(29), '🌟'));
    test('streak 30 → crown', () => expect(getStreakEmoji(30), '👑'));
    test('streak 99 → crown', () => expect(getStreakEmoji(99), '👑'));
    test('streak 100 → trophy', () => expect(getStreakEmoji(100), '🏆'));
    test('streak 999 → trophy', () => expect(getStreakEmoji(999), '🏆'));
  });

  group('getStreakTitle', () {
    test('streak 0 → Novato', () => expect(getStreakTitle(0), 'Novato'));
    test('streak 1 → Iniciado', () => expect(getStreakTitle(1), 'Iniciado'));
    test('streak 2 → Iniciado', () => expect(getStreakTitle(2), 'Iniciado'));
    test('streak 3 → Aprendiz', () => expect(getStreakTitle(3), 'Aprendiz'));
    test('streak 6 → Aprendiz', () => expect(getStreakTitle(6), 'Aprendiz'));
    test('streak 7 → Avanzado', () => expect(getStreakTitle(7), 'Avanzado'));
    test('streak 13 → Avanzado', () => expect(getStreakTitle(13), 'Avanzado'));
    test('streak 14 → Experto', () => expect(getStreakTitle(14), 'Experto'));
    test('streak 29 → Experto', () => expect(getStreakTitle(29), 'Experto'));
    test('streak 30 → Maestro', () => expect(getStreakTitle(30), 'Maestro'));
    test('streak 99 → Maestro', () => expect(getStreakTitle(99), 'Maestro'));
    test('streak 100 → Leyenda', () => expect(getStreakTitle(100), 'Leyenda'));
    test('streak 500 → Leyenda', () => expect(getStreakTitle(500), 'Leyenda'));
  });

  group('boundary conditions', () {
    test('getStreakMessage does not throw for very large streak', () {
      expect(() => getStreakMessage(99999), returnsNormally);
    });

    test('getStreakEmoji does not throw for very large streak', () {
      expect(() => getStreakEmoji(99999), returnsNormally);
    });

    test('getStreakTitle does not throw for very large streak', () {
      expect(() => getStreakTitle(99999), returnsNormally);
    });
  });
}
