import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/database/app_database.dart';
import 'package:target_vault/providers/app_providers.dart';
import 'package:target_vault/screens/item_detail_screen.dart';

Widget wrapWithProviders(Widget child) {
  final database = AppDatabase.memoryForTests();
  addTearDown(() async {
    await database.close();
  });
  return MultiProvider(
    providers: appProviders(database: database),
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: child,
    ),
  );
}

Item createTestItem({String? title}) {
  final now = DateTime.now();
  return Item(
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
