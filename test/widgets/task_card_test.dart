import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/models/task.dart';
import 'package:captus_mobile/shared/widgets/task_card.dart';
import '../helpers/test_helpers.dart';

void main() {
  // ── Rendering ─────────────────────────────────────────────────────────────

  group('TaskCard — rendering', () {
    testWidgets('renders task title', (tester) async {
      final task = makeTask(title: 'Entregar informe final');

      await tester.pumpWidget(makeScaffoldWidget(
        TaskCard(task: task),
      ));

      expect(find.text('Entregar informe final'), findsOneWidget);
    });

    testWidgets('renders description when present', (tester) async {
      final task = makeTask(
        title: 'Tarea',
        description: 'Descripción de prueba',
      );

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.text('Descripción de prueba'), findsOneWidget);
    });

    testWidgets('does not render description when absent', (tester) async {
      final task = makeTask(title: 'Sin descripción');

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.text('Descripción de prueba'), findsNothing);
    });

    testWidgets('renders category label when categoryName is set', (tester) async {
      final task = makeTask(title: 'Tarea', categoryName: 'Ingeniería');

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.text('Ingeniería'), findsOneWidget);
    });

    testWidgets('does NOT render category chip when categoryName is null', (tester) async {
      final task = makeTask(title: 'Sin categoría');

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.byIcon(Icons.label_outline), findsNothing);
    });
  });

  // ── Priority badge ─────────────────────────────────────────────────────────

  group('TaskCard — priority badge', () {
    testWidgets('shows "Alta" badge for high priority', (tester) async {
      final task = makeTask(priority: TaskPriority.high);

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.text('Alta'), findsOneWidget);
    });

    testWidgets('shows "Media" badge for medium priority', (tester) async {
      final task = makeTask(priority: TaskPriority.medium);

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.text('Media'), findsOneWidget);
    });

    testWidgets('shows "Baja" badge for low priority', (tester) async {
      final task = makeTask(priority: TaskPriority.low);

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.text('Baja'), findsOneWidget);
    });
  });

  // ── Completed state ────────────────────────────────────────────────────────

  group('TaskCard — completed state', () {
    testWidgets('completed card renders title with strikethrough', (tester) async {
      final task = makeCompletedTask(title: 'Tarea completada');

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      final textWidget = tester.widget<Text>(find.text('Tarea completada'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('completed checkbox is filled', (tester) async {
      final task = makeCompletedTask();

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      // The check icon inside _CircleCheckbox is only rendered when completed
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('pending task does not show check icon in checkbox', (tester) async {
      final task = makeTask(title: 'Pendiente');

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });
  });

  // ── Callbacks ─────────────────────────────────────────────────────────────

  group('TaskCard — tap callbacks', () {
    testWidgets('onTap is called when card body is tapped', (tester) async {
      bool tapped = false;
      final task = makeTask();

      await tester.pumpWidget(makeScaffoldWidget(
        TaskCard(task: task, onTap: () => tapped = true),
      ));

      await tester.tap(find.text(task.title));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('onComplete is called when circle checkbox is tapped', (tester) async {
      bool completed = false;
      final task = makeTask();

      await tester.pumpWidget(makeScaffoldWidget(
        TaskCard(task: task, onComplete: () => completed = true),
      ));

      // Find the animated container used as the checkbox (circle shape)
      final checkboxFinder = find.byWidgetPredicate(
        (w) =>
            w is AnimatedContainer &&
            (w.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      );
      await tester.tap(checkboxFinder.first);
      await tester.pump();

      expect(completed, isTrue);
    });
  });

  // ── Subtasks progress ─────────────────────────────────────────────────────

  group('TaskCard — subtask progress', () {
    testWidgets('shows subtask progress when subtasks exist', (tester) async {
      final task = makeTask(
        subtasks: [
          const SubTask(id: '1', title: 'A', isCompleted: true),
          const SubTask(id: '2', title: 'B', isCompleted: false),
        ],
      );

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.textContaining('/'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "1/2" for 1/2 completed', (tester) async {
      final task = makeTask(
        subtasks: [
          const SubTask(id: '1', title: 'A', isCompleted: true),
          const SubTask(id: '2', title: 'B', isCompleted: false),
        ],
      );

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('shows 50% when 1 of 2 subtasks complete', (tester) async {
      final task = makeTask(
        subtasks: [
          const SubTask(id: '1', title: 'A', isCompleted: true),
          const SubTask(id: '2', title: 'B', isCompleted: false),
        ],
      );

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('hides subtask bar when showSubtaskProgress=false', (tester) async {
      final task = makeTask(
        subtasks: [
          const SubTask(id: '1', title: 'A', isCompleted: true),
        ],
      );

      await tester.pumpWidget(makeScaffoldWidget(
        TaskCard(task: task, showSubtaskProgress: false),
      ));

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('subtarea'), findsNothing);
    });

    testWidgets('hides subtask section when no subtasks', (tester) async {
      final task = makeTask();

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  // ── Overdue state ──────────────────────────────────────────────────────────

  group('TaskCard — overdue state', () {
    testWidgets('overdue task renders with reduced opacity', (tester) async {
      final task = makeOverdueTask();

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      final opacityWidget = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacityWidget.opacity, 0.75);
    });

    testWidgets('non-overdue task has full opacity', (tester) async {
      final task = makeTask();

      await tester.pumpWidget(makeScaffoldWidget(TaskCard(task: task)));

      final opacityWidget = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacityWidget.opacity, 1.0);
    });
  });
}
