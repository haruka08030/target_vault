import 'package:flutter_test/flutter_test.dart';

import 'package:target_vault/database/app_database.dart';
import 'package:target_vault/main.dart';

void main() {
  testWidgets('App launches and shows Target Vault', (WidgetTester tester) async {
    final db = AppDatabase.memoryForTests();
    addTearDown(() async => db.close());
    await tester.pumpWidget(TargetVaultApp(database: db));
    expect(find.text('TARGET VAULT'), findsOneWidget);
  });
}
