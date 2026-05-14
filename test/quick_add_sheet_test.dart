import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/database/app_database.dart';
import 'package:target_vault/providers/app_providers.dart';
import 'package:target_vault/screens/quick_add_sheet.dart';

Widget wrapWithProviders(Widget child) {
  final database = AppDatabase.memoryForTests();
  addTearDown(() async {
    await database.close();
  });
  return MultiProvider(
    providers: appProviders(database: database),
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

Item createTestItem() {
  final now = DateTime.now();
  return Item(
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
