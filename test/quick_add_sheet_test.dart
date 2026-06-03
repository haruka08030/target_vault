import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/models/item_status.dart';
import 'package:target_vault/models/vault_item.dart';
import 'package:target_vault/screens/quick_add_sheet.dart';

import 'support/in_memory_backend.dart';
import 'support/test_widget_providers.dart';

Widget wrapWithProviders(Widget child) {
  final backend = ItemTxTestBackend();
  addTearDown(backend.dispose);
  return MultiProvider(
    providers: testWidgetProviders(backend),
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

VaultItem createTestItem() {
  final now = DateTime.now();
  return VaultItem(
    id: 'test-id-quickadd',
    title: 'テストアイテム',
    targetAmount: 5000,
    currency: 'JPY',
    imagePath: null,
    targetDate: null,
    category: null,
    status: ItemStatus.saving,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  testWidgets('QuickAddSheet shows 入金 and 出金 segments', (WidgetTester tester) async {
    final item = createTestItem();
    await tester.pumpWidget(
      wrapWithProviders(QuickAddSheet(item: item, onAdded: () {})),
    );

    expect(find.text('入金'), findsOneWidget);
    expect(find.text('出金'), findsOneWidget);
  });

  testWidgets('QuickAddSheet shows item title', (WidgetTester tester) async {
    final item = createTestItem();
    await tester.pumpWidget(
      wrapWithProviders(QuickAddSheet(item: item, onAdded: () {})),
    );

    expect(find.text('テストアイテム'), findsOneWidget);
  });

  testWidgets('QuickAddSheet has amount input and submit button', (WidgetTester tester) async {
    final item = createTestItem();
    await tester.pumpWidget(
      wrapWithProviders(QuickAddSheet(item: item, onAdded: () {})),
    );

    expect(find.byType(TextField), findsWidgets);
    expect(find.text('入金する'), findsOneWidget);
  });
}
