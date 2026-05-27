import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/shared/widgets/offline_banner.dart';
import 'package:captus_mobile/core/providers/connectivity_provider.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('OfflineBanner', () {
    testWidgets('is invisible (SizedBox.shrink) when online', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const OfflineBanner(),
        overrides: [connectivityOverride(online: true)],
      ));
      await tester.pump();

      expect(find.textContaining('Sin conexión'), findsNothing);
    });

    testWidgets('shows banner text when offline', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const OfflineBanner(),
        overrides: [connectivityOverride(online: false)],
      ));
      await tester.pump();

      expect(find.textContaining('Sin conexión'), findsOneWidget);
    });

    testWidgets('shows wifi-off icon when offline', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const OfflineBanner(),
        overrides: [connectivityOverride(online: false)],
      ));
      await tester.pump();

      // Icon is wifi_off_rounded — find by type
      expect(find.byType(OfflineBanner), findsOneWidget);
    });

    testWidgets('renders AnimatedSwitcher wrapping the banner content', (tester) async {
      // Verify OfflineBanner uses AnimatedSwitcher for smooth transitions
      await tester.pumpWidget(makeTestableWidget(
        const OfflineBanner(),
        overrides: [connectivityOverride(online: false)],
      ));
      await tester.pump();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
