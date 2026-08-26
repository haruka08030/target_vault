import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/models/item_status.dart';
import 'package:target_vault/models/vault_item.dart';
import 'package:target_vault/screens/item_detail_screen.dart';

import 'support/in_memory_backend.dart';
import 'support/test_app.dart';
import 'support/test_widget_providers.dart';

Widget wrapWithProviders(Widget child) {
  final backend = ItemTxTestBackend();
  addTearDown(backend.dispose);
  return MultiProvider(
    providers: testWidgetProviders(backend),
    // 画面がローカライズされたので、テストでも delegates が要る。
    child: testMaterialApp(home: child),
  );
}

VaultItem createTestItem({String? title}) {
  final now = DateTime.now();
  return VaultItem(
    id: 'test-id-1',
    title: title ?? 'テスト貯金',
    targetAmount: 10000,
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
  testWidgets('ItemDetailScreen shows item title', (WidgetTester tester) async {
    final item = createTestItem(title: '旅行資金');
    await tester.pumpWidget(wrapWithProviders(ItemDetailScreen(item: item)));
    await tester.pump();

    expect(find.text('旅行資金'), findsWidgets);
  });

  testWidgets('ItemDetailScreen shows quick add FAB', (WidgetTester tester) async {
    final item = createTestItem();
    await tester.pumpWidget(wrapWithProviders(ItemDetailScreen(item: item)));
    await tester.pump();

    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
