import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/screens/home_screen.dart';

import 'support/in_memory_backend.dart';
import 'support/test_app.dart';
import 'support/test_widget_providers.dart';

void main() {
  testWidgets('App launches and shows Target Vault', (WidgetTester tester) async {
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
  });
}
