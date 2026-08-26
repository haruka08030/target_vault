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

/// 文字サイズ・画面幅・文字数を極端にしても、レイアウトが壊れないことを見る。
///
/// 主要タスクは「開いて、貯金箱の状態がわかる」こと。溢れて赤帯が出る、
/// あるいは要素が消えるようでは、その前提が崩れる。
VaultItem _item({
  required String id,
  required String title,
  double target = 400000,
  String? category,
  int sortOrder = 0,
}) {
  final now = DateTime(2026, 1, 1);
  return VaultItem(
    id: id,
    title: title,
    targetAmount: target,
    currency: 'JPY',
    category: category,
    status: ItemStatus.saving,
    sortOrder: sortOrder,
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> _pumpHome(
  WidgetTester tester,
  ItemTxTestBackend backend, {
  double textScale = 1.0,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * tester.view.devicePixelRatio;
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: testMaterialApp(
        home: MultiProvider(
          providers: testWidgetProviders(backend),
          child: const HomeScreen(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('文字サイズ最大でもホームが溢れない', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.addAll([
      _item(id: 'a', title: 'カメラ', target: 3000, sortOrder: 0),
      _item(id: 'b', title: 'whrw', sortOrder: 1),
      _item(id: 'c', title: '新しいノートパソコン', sortOrder: 2),
    ]);

    // iOS のアクセシビリティ最大に近い倍率。
    await _pumpHome(tester, backend, textScale: 2.0);

    expect(tester.takeException(), isNull);
  });

  testWidgets('長いタイトルでも溢れない', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.addAll([
      _item(
        id: 'a',
        title: 'とてもとても長い貯金箱の名前をつけてしまった場合のテスト',
        sortOrder: 0,
      ),
      _item(
        id: 'b',
        title: 'AnotherExtremelyLongVaultNameWithoutAnySpaces',
        sortOrder: 1,
      ),
    ]);

    await _pumpHome(tester, backend);

    expect(tester.takeException(), isNull);
  });

  testWidgets('狭い画面でも溢れない', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.addAll([
      _item(id: 'a', title: 'カメラ', sortOrder: 0),
      _item(id: 'b', title: 'whrw', sortOrder: 1),
      _item(id: 'c', title: '旅行', sortOrder: 2),
    ]);

    // iPhone SE 相当。
    await _pumpHome(tester, backend, size: const Size(320, 568));

    expect(tester.takeException(), isNull);
  });

  testWidgets('狭い画面 + 文字サイズ最大でも溢れない', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.addAll([
      _item(id: 'a', title: 'カメラ', sortOrder: 0),
      _item(id: 'b', title: 'whrw', sortOrder: 1),
    ]);

    await _pumpHome(
      tester,
      backend,
      textScale: 2.0,
      size: const Size(320, 568),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('オンボーディングも文字サイズ最大で溢れない', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);

    await _pumpHome(
      tester,
      backend,
      textScale: 2.0,
      size: const Size(320, 568),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('はじめる'), findsOneWidget);
  });

  group('アイテム詳細', () {
    Future<void> pumpDetail(
      WidgetTester tester, {
      double textScale = 1.0,
      Size size = const Size(390, 844),
      double amount = 65000,
    }) async {
      final backend = ItemTxTestBackend();
      addTearDown(backend.dispose);
      final item = VaultItem(
        id: 'a',
        title: 'カメラ',
        targetAmount: 120000,
        currency: 'JPY',
        targetDate: DateTime(2026, 12, 24),
        category: '家電',
        status: ItemStatus.saving,
        sortOrder: 0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      backend.items.add(item);
      final tx = FakeTransactionRepository(backend);
      await tx.addTransaction(
        itemId: 'a',
        amount: amount,
        date: DateTime(2026, 7, 1),
      );

      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: testMaterialApp(
            home: MultiProvider(
              providers: testWidgetProviders(backend),
              child: ItemDetailScreen(item: item),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('通常サイズで溢れない', (tester) async {
      await pumpDetail(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('文字サイズ最大で溢れない', (tester) async {
      await pumpDetail(tester, textScale: 2.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('狭い画面で溢れない', (tester) async {
      await pumpDetail(tester, size: const Size(320, 568));
      expect(tester.takeException(), isNull);
    });

    testWidgets('大きな金額でも溢れない', (tester) async {
      await pumpDetail(
        tester,
        size: const Size(320, 568),
        amount: 98765432,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('埋め戻し中でも溢れない', (tester) async {
      await pumpDetail(tester, amount: -50000, textScale: 1.5);
      expect(tester.takeException(), isNull);
    });
  });

  group('設定', () {
    testWidgets('文字サイズ最大で溢れない', (tester) async {
      final backend = ItemTxTestBackend();
      addTearDown(backend.dispose);
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: SizedBox.shrink(),
        ),
      );
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: testMaterialApp(
            home: MultiProvider(
              providers: testWidgetProviders(backend),
              child: const SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
    });
  });
}
