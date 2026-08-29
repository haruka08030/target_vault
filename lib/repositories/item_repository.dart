import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/vault_mappers.dart';
import '../models/item_status.dart';
import '../models/vault_item.dart';
import 'transaction_repository.dart';

abstract class ItemRepository {
  Stream<List<VaultItem>> watchAllItems();

  Future<VaultItem?> getItem(String id);

  Future<void> createItem({
    required String title,
    required double targetAmount,
    String? currency,
    String? imagePath,
    DateTime? targetDate,
    String? category,
    bool purchasedOnCredit = false,
  });

  Future<bool> convertSavingItemToRepayingOnCredit(
    String itemId, {
    required double targetAmount,
  });

  Future<void> updateItem(
    String id, {
    required String title,
    required double targetAmount,
    required String currency,
    required DateTime? targetDate,
    required String? category,
    required String? imagePath,
  });

  Future<void> updateItemStatus(String id, ItemStatus status);

  Future<void> deleteItem(String id);

  Future<void> updateItemsOrder(List<String> orderedIds);

  /// ホームの主役カードに固定する / 固定を解除する。
  ///
  /// 固定は最大1件。[pinned] が true のとき、他アイテムの固定は解除される。
  Future<void> setPinned(String id, bool pinned);

  /// 貯金箱を棚から下ろす（買わないことにした）。履歴は残す。
  ///
  /// 主役カードに固定されていた場合は固定も外す。
  Future<void> archiveItem(String id);

  /// アーカイブした貯金箱を貯金中に戻す。
  Future<void> unarchiveItem(String id);
}

class DriftItemRepository implements ItemRepository {
  DriftItemRepository(this._db, this._transactions);

  final AppDatabase _db;
  final TransactionRepository _transactions;
  final _uuid = const Uuid();

  @override
  Stream<List<VaultItem>> watchAllItems() {
    return _db.select(_db.items).watch().map((rows) {
      final list = rows.map(vaultItemFromRow).toList();
      list.sort(compareVaultItems);
      return list;
    });
  }

  @override
  Future<VaultItem?> getItem(String id) async {
    final row = await (_db.select(_db.items)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : vaultItemFromRow(row);
  }

  Future<int> _nextSortOrder() async {
    final rows = await (_db.select(_db.items)
          ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return 0;
    return rows.first.sortOrder + 1;
  }

  @override
  Future<void> createItem({
    required String title,
    required double targetAmount,
    String? currency,
    String? imagePath,
    DateTime? targetDate,
    String? category,
    bool purchasedOnCredit = false,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final status =
        purchasedOnCredit ? ItemStatus.repaying : ItemStatus.saving;
    final nextOrder = await _nextSortOrder();

    await _db.into(_db.items).insert(
      ItemsCompanion.insert(
        id: id,
        title: title,
        targetAmount: targetAmount,
        currency: Value(currency ?? 'JPY'),
        imagePath: Value(imagePath),
        targetDate: Value(targetDate),
        category: Value(category),
        status: status,
        sortOrder: Value(nextOrder),
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (purchasedOnCredit) {
      await _transactions.addTransaction(
        itemId: id,
        amount: -targetAmount,
        date: now,
        note: '追加時: 前借りで購入済み',
      );
    }
  }

  @override
  Future<bool> convertSavingItemToRepayingOnCredit(
    String itemId, {
    required double targetAmount,
  }) async {
    final item = await getItem(itemId);
    if (item == null || item.status != ItemStatus.saving) return false;
    final now = DateTime.now();
    await _transactions.addTransaction(
      itemId: itemId,
      amount: -targetAmount,
      date: now,
      note: '編集: 前借りで購入済みとして登録',
    );
    await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
      ItemsCompanion(
        status: const Value(ItemStatus.repaying),
        updatedAt: Value(now),
      ),
    );
    return true;
  }

  @override
  Future<void> updateItem(
    String id, {
    required String title,
    required double targetAmount,
    required String currency,
    required DateTime? targetDate,
    required String? category,
    required String? imagePath,
  }) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        title: Value(title),
        targetAmount: Value(targetAmount),
        currency: Value(currency),
        targetDate: Value(targetDate),
        category: Value(category),
        imagePath: Value(imagePath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updateItemStatus(String id, ItemStatus status) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    await (_db.delete(_db.items)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> setPinned(String id, bool pinned) async {
    await _db.transaction(() async {
      if (pinned) {
        await (_db.update(_db.items)..where((t) => t.isPinned.equals(true)))
            .write(const ItemsCompanion(isPinned: Value(false)));
      }
      await (_db.update(_db.items)..where((t) => t.id.equals(id)))
          .write(ItemsCompanion(isPinned: Value(pinned)));
    });
  }

  @override
  Future<void> archiveItem(String id) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        status: const Value(ItemStatus.archived),
        // 棚から下ろすので固定も外す。
        isPinned: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> unarchiveItem(String id) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        status: const Value(ItemStatus.saving),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updateItemsOrder(List<String> orderedIds) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.items)..where((t) => t.id.equals(orderedIds[i])))
            .write(
          ItemsCompanion(
            sortOrder: Value(i),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }
}
