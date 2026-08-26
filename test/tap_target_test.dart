import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/models/item_status.dart';
import 'package:target_vault/models/vault_item.dart';
import 'package:target_vault/screens/home_screen.dart';
import 'package:target_vault/screens/item_detail_screen.dart';
import 'package:target_vault/screens/settings_screen.dart';

import 'support/in_memory_backend.dart';
import 'support/test_app.dart';
import 'support/test_widget_providers.dart';

/// 押せるものは 44x44 pt 以上あること（iOS HIG / Material のガイドライン）。
///
/// 小さすぎるボタンは、片手操作や手の震えがあると押せない。
const double _minTapTarget = 44;

VaultItem _item() {
  final now = DateTime(2026, 1, 1);
  return VaultItem(
    id: 'a',
    title: 'カメラ',
    targetAmount: 120000,
    currency: 'JPY',
    targetDate: DateTime(2026, 12, 24),
    status: ItemStatus.saving,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

/// タップ可能な要素の実寸を検査する。
void _expectTapTargets(WidgetTester tester) {
  final failures = <String>[];

  void check(Finder finder, String kind) {
    for (final element in finder.evaluate()) {
      final size = element.size;
      if (size == null || size.isEmpty) continue;
      if (size.width < _minTapTarget || size.height < _minTapTarget) {
        final widget = element.widget;
        failures.add(
          '$kind ${widget.runtimeType} '
          '${size.width.toStringAsFixed(1)}x${size.height.toStringAsFixed(1)}',
        );
      }
    }
  }

  check(find.byType(IconButton), 'IconButton');
  check(find.byType(FilledButton), 'FilledButton');
  check(find.byType(OutlinedButton), 'OutlinedButton');
  check(find.byType(FloatingActionButton), 'FAB');

  expect(failures, isEmpty, reason: '44x44 pt 未満のタップ領域: $failures');
}

Future<void> _pump(WidgetTester tester, Widget screen) async {
  final backend = ItemTxTestBackend();
  addTearDown(backend.dispose);
  backend.items.add(_item());
  await FakeTransactionRepository(
    backend,
  ).addTransaction(itemId: 'a', amount: 45000);

  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    testMaterialApp(
      home: MultiProvider(
        providers: testWidgetProviders(backend),
        child: screen,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('ホームのボタンは 44x44 pt 以上', (tester) async {
    await _pump(tester, const HomeScreen());
    _expectTapTargets(tester);
  });

  testWidgets('貯金箱の詳細のボタンは 44x44 pt 以上', (tester) async {
    await _pump(tester, ItemDetailScreen(item: _item()));
    _expectTapTargets(tester);
  });

  testWidgets('設定のボタンは 44x44 pt 以上', (tester) async {
    await _pump(tester, const SettingsScreen());
    _expectTapTargets(tester);
  });
}
