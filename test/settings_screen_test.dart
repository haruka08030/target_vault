import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/app_locale_controller.dart';
import 'package:target_vault/database/settings_store.dart';
import 'package:target_vault/screens/settings_screen.dart';

import 'support/in_memory_backend.dart';
import 'support/test_app.dart';
import 'support/test_widget_providers.dart';

void main() {
  testWidgets('Settings language change updates AppLocaleController', (
    WidgetTester tester,
  ) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    final providers = testWidgetProviders(backend);

    await tester.pumpWidget(
      testMaterialAppWithProviders(
        providers: providers,
        child: const SettingsScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('言語'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    final localeController = tester
        .element(find.byType(SettingsScreen))
        .read<AppLocaleController>();
    expect(localeController.locale, const Locale('en'));

    final settings = tester
        .element(find.byType(SettingsScreen))
        .read<SettingsStore>();
    expect(await settings.getAppLocaleCode(), 'en');

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Base currency'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('言語'), findsNothing);
  });
}
