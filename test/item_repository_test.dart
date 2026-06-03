import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/models/item_status.dart';

import 'support/in_memory_backend.dart';

void main() {
  group('ItemRepository.createItem', () {
    test(
      'purchasedOnCredit false creates saving item with no transactions',
      () async {
        final b = ItemTxTestBackend();
        addTearDown(b.dispose);
        final items = FakeItemRepository(b);
        final txs = FakeTransactionRepository(b);

        await items.createItem(
          title: 'Save only',
          targetAmount: 50_000,
          purchasedOnCredit: false,
        );

        final row = b.items.firstWhere((e) => e.title == 'Save only');
        expect(row.status, ItemStatus.saving);
        expect(await txs.getCurrentAmount(row.id), 0.0);
      },
    );

    test(
      'purchasedOnCredit true creates repaying item with -target balance',
      () async {
        final b = ItemTxTestBackend();
        addTearDown(b.dispose);
        final items = FakeItemRepository(b);
        final txs = FakeTransactionRepository(b);
        const target = 99_999.0;

        await items.createItem(
          title: 'Already bought',
          targetAmount: target,
          purchasedOnCredit: true,
        );

        final row = b.items.firstWhere((e) => e.title == 'Already bought');
        expect(row.status, ItemStatus.repaying);
        expect(await txs.getCurrentAmount(row.id), -target);
      },
    );
  });

  group('ItemRepository.convertSavingItemToRepayingOnCredit', () {
    test(
      'adds -target tx and repaying when item was saving with prior balance',
      () async {
        final b = ItemTxTestBackend();
        addTearDown(b.dispose);
        final items = FakeItemRepository(b);
        final txs = FakeTransactionRepository(b);

        await items.createItem(title: 'Later bought', targetAmount: 100_000);
        final row = b.items.firstWhere((e) => e.title == 'Later bought');
        await txs.addTransaction(itemId: row.id, amount: 30_000);

        final ok = await items.convertSavingItemToRepayingOnCredit(
          row.id,
          targetAmount: 100_000,
        );
        expect(ok, isTrue);

        final updated = await items.getItem(row.id);
        expect(updated!.status, ItemStatus.repaying);
        expect(await txs.getCurrentAmount(row.id), -70_000.0);
      },
    );

    test('returns false when item is not saving', () async {
      final b = ItemTxTestBackend();
      addTearDown(b.dispose);
      final items = FakeItemRepository(b);

      await items.createItem(
        title: 'Repay',
        targetAmount: 10_000,
        purchasedOnCredit: true,
      );
      final row = b.items.firstWhere((e) => e.title == 'Repay');

      final ok = await items.convertSavingItemToRepayingOnCredit(
        row.id,
        targetAmount: 10_000,
      );
      expect(ok, isFalse);
    });
  });
}
