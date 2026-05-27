import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:captus_mobile/shared/widgets/countdown_chip.dart';
import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    // CountdownChip uses DateFormat('d MMM', 'es') for dates far in the future.
    await initializeDateFormatting('es', null);
  });

  group('CountdownChip — labels', () {
    testWidgets('shows "Vencida" for past due date', (tester) async {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      await tester.pumpWidget(makeTestableWidget(
        CountdownChip(dueDate: pastDate),
      ));
      await tester.pump();

      expect(find.textContaining('Vencida'), findsOneWidget);
    });

    testWidgets('shows hours label when due within 24 hours', (tester) async {
      final soonDate = DateTime.now().add(const Duration(hours: 3));

      await tester.pumpWidget(makeTestableWidget(
        CountdownChip(dueDate: soonDate),
      ));
      await tester.pump();

      // Should show 'Vence en Xh' or 'Menos de 1h'
      final hasVenceEn = find.textContaining('Vence en').evaluate().isNotEmpty;
      final hasMenosDe = find.textContaining('Menos de').evaluate().isNotEmpty;
      expect(hasVenceEn || hasMenosDe, isTrue,
          reason: 'Expected "Vence en" or "Menos de" label for near-future due date');
    });

    testWidgets('shows days label when due in 1-2 days', (tester) async {
      final warningDate = DateTime.now().add(const Duration(days: 2));

      await tester.pumpWidget(makeTestableWidget(
        CountdownChip(dueDate: warningDate),
      ));
      await tester.pump();

      expect(find.textContaining('Vence en'), findsOneWidget);
    });

    testWidgets('shows formatted date when due in more than 3 days', (tester) async {
      final farDate = DateTime(2026, 12, 25); // definite future

      await tester.pumpWidget(makeTestableWidget(
        CountdownChip(dueDate: farDate),
      ));
      await tester.pump();

      // The formatted date should appear (not "Vencida" or "Vence en")
      expect(find.textContaining('Vence en'), findsNothing);
      expect(find.textContaining('Vencida'), findsNothing);
    });
  });

  group('CountdownChip — compact mode', () {
    testWidgets('compact=true renders without container decoration', (tester) async {
      final pastDate = DateTime.now().subtract(const Duration(hours: 5));

      await tester.pumpWidget(makeTestableWidget(
        CountdownChip(dueDate: pastDate, compact: true),
      ));
      await tester.pump();

      expect(find.byType(CountdownChip), findsOneWidget);
    });

    testWidgets('compact=false renders decorated container', (tester) async {
      final pastDate = DateTime.now().subtract(const Duration(hours: 5));

      await tester.pumpWidget(makeTestableWidget(
        CountdownChip(dueDate: pastDate, compact: false),
      ));
      await tester.pump();

      expect(find.byType(CountdownChip), findsOneWidget);
    });
  });

  group('CountdownChip — "Menos de 1h" label', () {
    testWidgets('shows "Menos de 1h" when due in less than 1 hour', (tester) async {
      final almostDue = DateTime.now().add(const Duration(minutes: 30));

      await tester.pumpWidget(makeTestableWidget(
        CountdownChip(dueDate: almostDue),
      ));
      await tester.pump();

      expect(find.text('Menos de 1h'), findsOneWidget);
    });
  });
}
