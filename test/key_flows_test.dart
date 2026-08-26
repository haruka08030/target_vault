import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/models/item_status.dart';
import 'package:target_vault/models/vault_item.dart';
import 'package:target_vault/screens/home_screen.dart';

import 'support/in_memory_backend.dart';
import 'support/test_app.dart';
import 'support/test_widget_providers.dart';

/// 完了条件のうち「タップ数」を機械的に検証する。
///
/// - 起動 → 入金完了: 3タップ以内
/// - 0件 → 貯金箱の作成画面に到達: 1タップ
Future<void> _pumpHome(WidgetTester tester, ItemTxTestBackend backend) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

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
}

void main() {
  testWidgets('起動 → 入金完了が3タップ以内', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    final now = DateTime(2026, 1, 1);
    backend.items.add(
      VaultItem(
        id: 'a',
        title: 'カメラ',
        targetAmount: 120000,
        currency: 'JPY',
        status: ItemStatus.saving,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _pumpHome(tester, backend);
    var taps = 0;

    // 1タップ目: 主役カードの「貯金する」
    await tester.tap(find.text('貯金する'));
    taps++;
    await tester.pumpAndSettle();

    // 金額入力（タップ数には数えない。キーボード入力）
    await tester.enterText(find.byType(TextField).first, '5000');
    await tester.pump();

    // 2タップ目: 入金を確定
    await tester.tap(find.text('入金する'));
    taps++;
    await tester.pumpAndSettle();

    expect(taps, lessThanOrEqualTo(3), reason: '入金までのタップ数');
    expect(backend.balances['a'], 5000, reason: '入金が記録されていること');
  });

  testWidgets('0件 → 貯金箱の作成画面へ1タップで到達', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);

    await _pumpHome(tester, backend);

    // 空状態では選択肢は1つだけ
    expect(find.text('はじめる'), findsOneWidget);

    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();

    // 作成画面に到達している
    expect(find.text('タイトル'), findsWidgets);
  });
}
