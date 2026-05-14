import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/database/app_database.dart';
import 'package:target_vault/main.dart';

void main() {
  testWidgets('HomeScreen shows title and items section', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memoryForTests();
    addTearDown(() async => db.close());
    await tester.pumpWidget(TargetVaultApp(database: db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('TARGET VAULT'), findsOneWidget);
    expect(find.text('Active Goals'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('HomeScreen shows settings button', (WidgetTester tester) async {
    final db = AppDatabase.memoryForTests();
    addTearDown(() async => db.close());
    await tester.pumpWidget(TargetVaultApp(database: db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
