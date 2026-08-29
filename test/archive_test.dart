import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:target_vault/models/item_status.dart';
import 'package:target_vault/models/vault_item.dart';
import 'package:target_vault/screens/completed_items_screen.dart';
import 'package:target_vault/screens/home_screen.dart';
import 'package:target_vault/services/vault_selection.dart';
import 'package:target_vault/widgets/vault_tile.dart';

import 'support/in_memory_backend.dart';
import 'support/test_app.dart';
import 'support/test_widget_providers.dart';

VaultItem _item({
  required String id,
  required String title,
  ItemStatus status = ItemStatus.saving,
  bool isPinned = false,
}) {
  final now = DateTime(2026, 1, 1);
  return VaultItem(
    id: id,
    title: title,
    targetAmount: 10000,
    currency: 'JPY',
    status: status,
    sortOrder: 0,
    isPinned: isPinned,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('ItemStatus', () {
    test('棚に並ぶのは貯金中と埋め戻し中だけ', () {
      expect(ItemStatus.saving.isActive, isTrue);
      expect(ItemStatus.repaying.isActive, isTrue);
      expect(ItemStatus.completed.isActive, isFalse);
      expect(ItemStatus.archived.isActive, isFalse);
    });

    test('未知の値は貯金中として読む', () {
      expect(ItemStatus.fromDb('archived'), ItemStatus.archived);
      expect(ItemStatus.fromDb('unknown'), ItemStatus.saving);
    });
  });

  test('アーカイブは主役に選ばれない', () {
    final snapshots = [
      VaultSnapshot(
        item: _item(id: 'a', title: 'やめた', status: ItemStatus.archived),
        balance: 0,
      ),
    ];
    expect(selectHeroVault(snapshots), isNull);
  });

  test('アーカイブすると固定も外れる', () async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.add(_item(id: 'a', title: '固定中', isPinned: true));
    final repo = FakeItemRepository(backend);

    await repo.archiveItem('a');

    final item = await repo.getItem('a');
    expect(item!.status, ItemStatus.archived);
    expect(item.isPinned, isFalse);
  });

  test('アーカイブから戻すと貯金中になる', () async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.add(
      _item(id: 'a', title: 'やめた', status: ItemStatus.archived),
    );
    final repo = FakeItemRepository(backend);

    await repo.unarchiveItem('a');

    expect((await repo.getItem('a'))!.status, ItemStatus.saving);
  });

  testWidgets('アーカイブはホームの棚に出ない', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.addAll([
      _item(id: 'a', title: '貯金中'),
      _item(id: 'b', title: 'やめた', status: ItemStatus.archived),
    ]);

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

    expect(find.byType(VaultTile), findsOneWidget);
    expect(find.text('やめた'), findsNothing);
  });

  testWidgets('完了とアーカイブが2セクションに分かれて並ぶ', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.addAll([
      _item(id: 'a', title: '買えた', status: ItemStatus.completed),
      _item(id: 'b', title: 'やめた', status: ItemStatus.archived),
    ]);

    await tester.pumpWidget(
      testMaterialApp(
        home: MultiProvider(
          providers: testWidgetProviders(backend),
          child: const CompletedItemsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('完了'), findsOneWidget);
    expect(find.text('アーカイブ'), findsOneWidget);
    expect(find.text('買えた'), findsOneWidget);
    expect(find.text('やめた'), findsOneWidget);
    // アーカイブだけ「棚に戻す」を持つ
    expect(find.text('棚に戻す'), findsOneWidget);
  });

  testWidgets('棚に戻すを押すと一覧から消える', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);
    backend.items.add(
      _item(id: 'b', title: 'やめた', status: ItemStatus.archived),
    );

    await tester.pumpWidget(
      testMaterialApp(
        home: MultiProvider(
          providers: testWidgetProviders(backend),
          child: const CompletedItemsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('棚に戻す'));
    await tester.pumpAndSettle();

    expect(find.text('やめた'), findsNothing);
    expect(find.text('まだ何もありません'), findsOneWidget);
  });

  testWidgets('何も無ければ空状態を出す', (tester) async {
    final backend = ItemTxTestBackend();
    addTearDown(backend.dispose);

    await tester.pumpWidget(
      testMaterialApp(
        home: MultiProvider(
          providers: testWidgetProviders(backend),
          child: const CompletedItemsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('まだ何もありません'), findsOneWidget);
  });
}
