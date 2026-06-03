import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/screens/add_item_screen.dart';

import 'support/in_memory_backend.dart';
import 'support/test_app.dart';
import 'support/test_widget_providers.dart';

void main() {
  testWidgets('AddItemScreen shows English strings when locale is en', (
    WidgetTester tester,
  ) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    await tester.pumpWidget(
      testMaterialApp(
        locale: const Locale('en'),
        home: MultiProvider(
          providers: testWidgetProviders(backend),
          child: const AddItemScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Add item'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Target amount'), findsOneWidget);
    expect(find.text('Add photo (optional)'), findsOneWidget);
  });

  testWidgets('AddItemScreen shows Japanese strings when locale is ja', (
    WidgetTester tester,
  ) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    await tester.pumpWidget(
      testMaterialApp(
        home: MultiProvider(
          providers: testWidgetProviders(backend),
          child: const AddItemScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('アイテムを追加'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('タイトル'), findsOneWidget);
  });
}
