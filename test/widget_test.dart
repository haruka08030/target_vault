import 'package:flutter_test/flutter_test.dart';

import 'package:target_vault/main.dart';

void main() {
  testWidgets('App launches and shows Target Vault', (WidgetTester tester) async {
    await tester.pumpWidget(const TargetVaultApp());
    expect(find.text('Target Vault'), findsOneWidget);
  });
}
