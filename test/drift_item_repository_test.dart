import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/database/app_database.dart';
import 'package:target_vault/models/item_status.dart';
import 'package:target_vault/repositories/item_repository.dart';
import 'package:target_vault/repositories/transaction_repository.dart';

void main() {
  group('DriftItemRepository', () {
    late AppDatabase db;
    late ItemRepository items;
    late TransactionRepository txs;

    setUp(() {
      db = AppDatabase.memoryForTests();
      txs = DriftTransactionRepository(db);
      items = DriftItemRepository(db, txs);
    });

    tearDown(() => db.close());

    test('purchasedOnCredit creates repaying item with negative balance', () async {
      const target = 42_000.0;
      await items.createItem(
        title: 'On credit',
        targetAmount: target,
        purchasedOnCredit: true,
      );

      final all = await items.watchAllItems().first;
      final row = all.single;
      expect(row.status, ItemStatus.repaying);
      expect(await txs.getCurrentAmount(row.id), -target);
    });

    test('updateItemsOrder updates sort_order', () async {
      await items.createItem(title: 'A', targetAmount: 1);
      await items.createItem(title: 'B', targetAmount: 2);
      final initial = await items.watchAllItems().first;
      expect(initial[0].title, 'A');
      expect(initial[1].title, 'B');

      await items.updateItemsOrder([initial[1].id, initial[0].id]);

      final reordered = await items.watchAllItems().first;
      expect(reordered[0].title, 'B');
      expect(reordered[1].title, 'A');
    });
  });
}
