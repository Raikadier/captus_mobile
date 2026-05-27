import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/shared/widgets/streak_badge.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('StreakBadge — micro size', () {
    testWidgets('renders day count as text', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const StreakBadge(days: 7, size: StreakSize.micro),
      ));
      expect(find.text('7'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('renders 0 days', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const StreakBadge(days: 0, size: StreakSize.micro),
      ));
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders large day count', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const StreakBadge(days: 365, size: StreakSize.micro),
      ));
      expect(find.text('365'), findsOneWidget);
    });
  });

  group('StreakBadge — mini size (default)', () {
    testWidgets('renders day count with "días" label', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const StreakBadge(days: 14),
      ));
      expect(find.textContaining('14 días'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('is default size when size omitted', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const StreakBadge(days: 5),
      ));
      // mini has a Container with border — just ensure it renders without error
      expect(find.byType(StreakBadge), findsOneWidget);
    });
  });

  group('StreakBadge — hero size', () {
    testWidgets('renders large day count and "días consecutivos"', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const StreakBadge(days: 30, size: StreakSize.hero),
      ));
      expect(find.text('30'), findsOneWidget);
      expect(find.text('días consecutivos'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('renders with gradient container', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const StreakBadge(days: 100, size: StreakSize.hero),
      ));
      expect(find.byType(Container), findsWidgets);
    });
  });
}
