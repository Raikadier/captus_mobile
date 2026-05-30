import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:captus_mobile/core/services/local_storage_service.dart';
import 'package:captus_mobile/shared/widgets/offline_banner.dart';
import 'package:captus_mobile/shared/widgets/streak_badge.dart';
import 'package:captus_mobile/shared/widgets/empty_state.dart';
import 'package:captus_mobile/shared/widgets/task_card.dart';
import '../helpers/test_helpers.dart';

// ── Lightweight "home-like" smoke screen ─────────────────────────────────────
// The real HomeDashboardScreen pulls live Supabase data. Instead we test the
// component composition: StreakBadge, OfflineBanner, TaskCard, EmptyState
// all working together in a Riverpod shell — exactly what HomeDashboard does.

Widget _buildHomeShell({bool online = true, List<Widget> children = const []}) {
  return makeTestableWidget(
    Scaffold(
      body: Column(
        children: [
          OfflineBanner(),
          ...children,
        ],
      ),
    ),
    overrides: [connectivityOverride(online: online)],
  );
}

void main() {
  setUp(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'http://localhost:3000/api',
      'SUPABASE_URL': '',
      'SUPABASE_ANON_KEY': '',
    });
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.initialize();
  });

  // ── OfflineBanner integration ──────────────────────────────────────────────

  group('HomeDashboard — offline banner', () {
    testWidgets('shows banner when offline', (tester) async {
      await tester.pumpWidget(_buildHomeShell(online: false));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin conexión'), findsOneWidget);
    });

    testWidgets('hides banner when online', (tester) async {
      await tester.pumpWidget(_buildHomeShell(online: true));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin conexión'), findsNothing);
    });
  });

  // ── StreakBadge in context ─────────────────────────────────────────────────

  group('HomeDashboard — streak section', () {
    testWidgets('renders StreakBadge with a days value', (tester) async {
      await tester.pumpWidget(_buildHomeShell(
        children: [const StreakBadge(days: 7)],
      ));
      await tester.pump();

      expect(find.textContaining('7 días'), findsOneWidget);
    });

    testWidgets('renders StreakBadge with 0 days', (tester) async {
      await tester.pumpWidget(_buildHomeShell(
        children: [const StreakBadge(days: 0)],
      ));
      await tester.pump();

      expect(find.textContaining('0 días'), findsOneWidget);
    });
  });

  // ── Task list section ──────────────────────────────────────────────────────

  group('HomeDashboard — task list', () {
    testWidgets('shows EmptyState when task list is empty', (tester) async {
      await tester.pumpWidget(_buildHomeShell(
        children: [
          EmptyState(
            icon: Icons.check_box_outline_blank,
            title: 'No tienes tareas pendientes',
            subtitle: '¡Excelente trabajo!',
          ),
        ],
      ));
      await tester.pump();

      expect(find.text('No tienes tareas pendientes'), findsOneWidget);
    });

    testWidgets('shows TaskCard when task list has items', (tester) async {
      final task = makeTask(title: 'Estudiar para parcial');

      await tester.pumpWidget(_buildHomeShell(
        children: [TaskCard(task: task)],
      ));
      await tester.pump();

      expect(find.text('Estudiar para parcial'), findsOneWidget);
    });

    testWidgets('multiple tasks render multiple cards', (tester) async {
      final tasks = [
        makeTask(id: 1, title: 'Tarea A'),
        makeTask(id: 2, title: 'Tarea B'),
        makeTask(id: 3, title: 'Tarea C'),
      ];

      await tester.pumpWidget(_buildHomeShell(
        children: tasks.map((t) => TaskCard(task: t)).toList(),
      ));
      await tester.pump();

      expect(find.byType(TaskCard), findsNWidgets(3));
    });
  });

  // ── Offline + data combination ─────────────────────────────────────────────

  group('HomeDashboard — offline with data', () {
    testWidgets('shows both offline banner and task cards simultaneously', (tester) async {
      final task = makeTask(title: 'Tarea offline');

      await tester.pumpWidget(_buildHomeShell(
        online: false,
        children: [TaskCard(task: task)],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin conexión'), findsOneWidget);
      expect(find.text('Tarea offline'), findsOneWidget);
    });
  });
}
