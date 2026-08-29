import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/models/item_status.dart';
import 'package:target_vault/models/vault_item.dart';
import 'package:target_vault/screens/home_screen.dart';
import 'package:target_vault/widgets/vault_hero_card.dart';
import 'package:target_vault/widgets/vault_tile.dart';

import 'support/in_memory_backend.dart';
import 'support/test_app.dart';
import 'support/test_widget_providers.dart';

VaultItem _item({
  required String id,
  required String title,
  double target = 10000,
  DateTime? targetDate,
  String? category,
  bool isPinned = false,
  int sortOrder = 0,
}) {
  final now = DateTime(2026, 1, 1);
  return VaultItem(
    id: id,
    title: title,
    targetAmount: target,
    currency: 'JPY',
    targetDate: targetDate,
    category: category,
    status: ItemStatus.saving,
    sortOrder: sortOrder,
    isPinned: isPinned,
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> _pumpHome(WidgetTester tester, ItemTxTestBackend backend) async {
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
  testWidgets('貯金箱が0件ならオンボーディングを出す', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);

    await _pumpHome(tester, backend);

    expect(find.text('はじめる'), findsOneWidget);
    expect(find.text('欲しいものへ、こつこつ貯金'), findsOneWidget);
    // 合計や純資産は出さない
    expect(find.text('貯めたお金'), findsNothing);
    expect(find.text('借りたお金'), findsNothing);
  });

  testWidgets('貯金箱があれば主役カードとアプリ名を出す', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.add(_item(id: 'a', title: 'MacBook'));

    await _pumpHome(tester, backend);

    expect(find.text('Target Vault'), findsOneWidget);
    expect(find.byType(VaultHeroCard), findsOneWidget);
    // 主役カードと棚のタイルの両方に出る（ピックアップとして再掲）
    expect(find.text('MacBook'), findsNWidgets(2));
    expect(find.text('貯金する'), findsOneWidget);
    // 主役は棚からも抜かない（ピックアップとして再掲する）
    expect(find.byType(VaultTile), findsOneWidget);
  });

  testWidgets('残高から「あといくら」を出す', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.add(_item(id: 'a', title: 'カメラ', target: 10000));
    await FakeTransactionRepository(
      backend,
    ).addTransaction(itemId: 'a', amount: 3000);

    await _pumpHome(tester, backend);

    expect(find.textContaining('あと'), findsWidgets);
    expect(find.textContaining('7,000'), findsWidgets);
  });

  testWidgets('主役も含めて全ての貯金箱がタイルに並ぶ', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.addAll([
      _item(
        id: 'a',
        title: '近いほう',
        targetDate: DateTime(2026, 3, 1),
        sortOrder: 0,
      ),
      _item(
        id: 'b',
        title: '遠いほう',
        targetDate: DateTime(2027, 3, 1),
        sortOrder: 1,
      ),
    ]);

    await _pumpHome(tester, backend);

    // 目標日が近いほうが主役。ただしタイルからは抜かない。
    expect(find.byType(VaultHeroCard), findsOneWidget);
    expect(find.byType(VaultTile), findsNWidgets(2));
    expect(find.text('貯金箱'), findsOneWidget);

    // 主役のタイルは印で見分けられる
    final heroTiles = tester
        .widgetList<VaultTile>(find.byType(VaultTile))
        .where((t) => t.isHero)
        .toList();
    expect(heroTiles, hasLength(1));
    expect(heroTiles.single.snapshot.item.title, '近いほう');
  });

  testWidgets('ピン留めが自動選定より優先される', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.addAll([
      _item(
        id: 'a',
        title: '目標日が近い',
        targetDate: DateTime(2026, 3, 1),
        sortOrder: 0,
      ),
      _item(id: 'b', title: 'ピン留め', isPinned: true, sortOrder: 1),
    ]);

    await _pumpHome(tester, backend);

    final hero = tester.widget<VaultHeroCard>(find.byType(VaultHeroCard));
    expect(hero.snapshot.item.title, 'ピン留め');
  });

  testWidgets('設定と完了への導線がある', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.add(_item(id: 'a', title: 'MacBook'));

    await _pumpHome(tester, backend);

    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });

  testWidgets('カテゴリフィルタでタイルを絞り込む', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.addAll([
      _item(
        id: 'a',
        title: '主役',
        targetDate: DateTime(2026, 3, 1),
        sortOrder: 0,
      ),
      _item(id: 'b', title: '家電', category: '家電', sortOrder: 1),
      _item(id: 'c', title: '旅行', category: '旅行', sortOrder: 2),
    ]);

    await _pumpHome(tester, backend);
    // 主役も含めて3件
    expect(find.byType(VaultTile), findsNWidgets(3));

    await tester.tap(find.widgetWithText(FilterChip, '家電'));
    await tester.pumpAndSettle();

    expect(find.byType(VaultTile), findsOneWidget);
  });
}
