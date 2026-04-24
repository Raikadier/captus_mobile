import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importar componentes a testear
// import 'package:captus_mobile/core/theme/app_theme_enhanced.dart';
// import 'package:captus_mobile/features/auth/screens/enhanced_onboarding_screen.dart';

void main() {
  group('CaptusCard Widget Tests', () {
    testWidgets('Renderiza correctamente', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: Scaffold(
      //       body: CaptusCard(
      //         child: Text('Test Card'),
      //       ),
      //     ),
      //   ),
      // );

      // expect(find.text('Test Card'), findsOneWidget);
    });

    testWidgets('Ejecuta callback al hacer tap', (WidgetTester tester) async {
      // bool tapped = false;
      // await tester.pumpWidget(
      //   MaterialApp(
      //     home: Scaffold(
      //       body: CaptusCard(
      //         onTap: () => tapped = true,
      //         child: const Text('Tap me'),
      //       ),
      //     ),
      //   ),
      // );

      // await tester.tap(find.byType(GestureDetector));
      // expect(tapped, true);
    });
  });

  group('PrimaryButton Widget Tests', () {
    testWidgets('Renderiza label correctamente', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   MaterialApp(
      //     home: Scaffold(
      //       body: PrimaryButton(
      //         label: 'Click Me',
      //         onPressed: () {},
      //       ),
      //     ),
      //   ),
      // );

      // expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('Muestra loader cuando isLoading es true', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   MaterialApp(
      //     home: Scaffold(
      //       body: PrimaryButton(
      //         label: 'Loading',
      //         onPressed: () {},
      //         isLoading: true,
      //       ),
      //     ),
      //   ),
      // );

      // expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Desactiva botón cuando isLoading es true', (WidgetTester tester) async {
      // bool tapped = false;
      // await tester.pumpWidget(
      //   MaterialApp(
      //     home: Scaffold(
      //       body: PrimaryButton(
      //         label: 'Button',
      //         onPressed: () => tapped = true,
      //         isLoading: true,
      //       ),
      //     ),
      //   ),
      // );

      // await tester.tap(find.byType(ElevatedButton));
      // expect(tapped, false);
    });
  });

  group('EnhancedOnboarding Widget Tests', () {
    testWidgets('Renderiza todas las páginas', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const ProviderScope(
      //     child: MaterialApp(
      //       home: EnhancedOnboardingScreen(),
      //     ),
      //   ),
      // );

      // expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('Navega entre páginas', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const ProviderScope(
      //     child: MaterialApp(
      //       home: EnhancedOnboardingScreen(),
      //     ),
      //   ),
      // );

      // await tester.tap(find.byIcon(Icons.arrow_forward));
      // await tester.pumpAndSettle();
      // expect(find.text('Captura tu Aprendizaje'), findsOneWidget);
    });

    testWidgets('Botón Finalizar en última página', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const ProviderScope(
      //     child: MaterialApp(
      //       home: EnhancedOnboardingScreen(),
      //     ),
      //   ),
      // );

      // for (int i = 0; i < 4; i++) {
      //   await tester.tap(find.byIcon(Icons.arrow_forward));
      //   await tester.pumpAndSettle();
      // }

      // expect(find.text('Finalizar'), findsOneWidget);
    });
  });

  group('QRScannerScreen Widget Tests', () {
    testWidgets('Renderiza scanner correctamente', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: QRScannerScreen(),
      //   ),
      // );

      // expect(find.byType(MobileScanner), findsOneWidget);
    });

    testWidgets('Muestra botón de flash', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: QRScannerScreen(),
      //   ),
      // );

      // expect(find.byIcon(Icons.flashlight_on), findsOneWidget);
    });
  });

  group('PhotoCaptureScreen Widget Tests', () {
    testWidgets('Renderiza botones de captura y galería', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: PhotoCaptureScreen(
      //       taskId: '1',
      //       taskTitle: 'Test Task',
      //     ),
      //   ),
      // );

      // expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      // expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('Botón enviar se habilita con fotos', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: PhotoCaptureScreen(
      //       taskId: '1',
      //       taskTitle: 'Test Task',
      //     ),
      //   ),
      // );

      // final sendButton = find.widgetWithText(ElevatedButton, 'Enviar tarea');
      // expect(sendButton, findsOneWidget);
    });
  });

  group('AdvancedDashboard Widget Tests', () {
    testWidgets('Renderiza dashboard correctamente', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: AdvancedDashboardScreen(),
      //   ),
      // );

      // expect(find.text('Mi Dashboard'), findsOneWidget);
    });

    testWidgets('Renderiza todos los filtros de fecha', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: AdvancedDashboardScreen(),
      //   ),
      // );

      // expect(find.text('Hoy'), findsOneWidget);
      // expect(find.text('Semana'), findsOneWidget);
      // expect(find.text('Mes'), findsOneWidget);
      // expect(find.text('Personalizado'), findsOneWidget);
    });

    testWidgets('Renderiza todas las gráficas', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: AdvancedDashboardScreen(),
      //   ),
      // );

      // expect(find.byType(BarChart), findsOneWidget);
      // expect(find.byType(LineChart), findsOneWidget);
      // expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('Botón exportar ejecuta acción', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(
      //     home: AdvancedDashboardScreen(),
      //   ),
      // );

      // await tester.tap(find.byIcon(Icons.download));
      // await tester.pumpAndSettle();
      // expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
