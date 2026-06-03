import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/screens/home_screen.dart';

import 'support/in_memory_backend.dart';
import 'support/test_app.dart';
import 'support/test_widget_providers.dart';

void main() {
  testWidgets('HomeScreen shows title and items section', (
    WidgetTester tester,
  ) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    await tester.pumpWidget(
      testMaterialApp(
        home: MultiProvider(
          providers: testWidgetProviders(backend),
          child: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('TARGET VAULT'), findsOneWidget);
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('進行中'), findsOneWidget);
    expect(find.text('完了'), findsOneWidget);
    expect(find.text('利用可能純資産'), findsNothing);
    expect(find.byIcon(Icons.person), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('貯めたお金'), findsOneWidget);
    expect(find.text('借りたお金'), findsOneWidget);
  });

  testWidgets('HomeScreen shows settings button', (WidgetTester tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    await tester.pumpWidget(
      testMaterialApp(
        home: MultiProvider(
          providers: testWidgetProviders(backend),
          child: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
