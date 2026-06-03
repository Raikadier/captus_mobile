import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/shared/widgets/empty_state.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('EmptyState widget', () {
    testWidgets('renders icon, title, and subtitle', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(
          icon: Icons.check_box_outline_blank,
          title: 'Sin tareas',
          subtitle: 'Crea tu primera tarea',
        ),
      ));

      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
      expect(find.text('Sin tareas'), findsOneWidget);
      expect(find.text('Crea tu primera tarea'), findsOneWidget);
    });

    testWidgets('does NOT render action button when actionLabel is null', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(
          icon: Icons.note_outlined,
          title: 'Sin notas',
          subtitle: 'Empieza a escribir',
        ),
      ));

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders action button when actionLabel + onAction provided', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        EmptyState(
          icon: Icons.add,
          title: 'Vacío',
          subtitle: 'Agrega algo',
          actionLabel: 'Agregar',
          onAction: () {},
        ),
      ));

      expect(find.text('Agregar'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('action button triggers onAction callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(makeTestableWidget(
        EmptyState(
          icon: Icons.add,
          title: 'Vacío',
          subtitle: 'Agrega algo',
          actionLabel: 'Agregar',
          onAction: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does NOT render button when onAction is null (even if label provided)', (tester) async {
      // If only actionLabel is set but onAction is null → button should not appear
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(
          icon: Icons.add,
          title: 'Vacío',
          subtitle: 'No hay acción',
          actionLabel: 'Hacer algo',
          // onAction intentionally omitted
        ),
      ));

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('is centred in the layout', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(
          icon: Icons.search_off,
          title: 'Sin resultados',
          subtitle: 'Prueba otro término',
        ),
      ));

      expect(find.byType(Center), findsWidgets);
    });
  });
}
