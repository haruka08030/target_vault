import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/vault_mappers.dart';
import '../models/vault_transaction.dart';

abstract class TransactionRepository {
  Stream<List<VaultTransaction>> watchByItem(String itemId);

  Future<double> getCurrentAmount(String itemId);

  /// 全アイテムの残高をまとめて返す（itemId -> 残高）。
  ///
  /// カードごとに [getCurrentAmount] を呼ぶと N 件で N 回のクエリになるため、
  /// 一覧表示ではこちらを使う。取引が無いアイテムはキーを持たない。
  Stream<Map<String, double>> watchAllBalances();

  Future<void> addTransaction({
    required String itemId,
    required double amount,
    DateTime? date,
    String? note,
  });

  Future<void> updateTransaction(
    String id, {
    double? amount,
    DateTime? date,
    String? note,
  });

  Future<void> deleteTransaction(String id);

  Future<VaultTransaction?> getTransaction(String id);
}

class DriftTransactionRepository implements TransactionRepository {
  DriftTransactionRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  @override
  Stream<List<VaultTransaction>> watchByItem(String itemId) {
    return (_db.select(_db.transactions)
          ..where((t) => t.itemId.equals(itemId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch()
        .map((rows) => rows.map(vaultTransactionFromRow).toList());
  }

  @override
  Future<double> getCurrentAmount(String itemId) async {
    final sum = _db.transactions.amount.sum();
    final query = _db.selectOnly(_db.transactions)
      ..addColumns([sum])
      ..where(_db.transactions.itemId.equals(itemId));
    final row = await query.getSingleOrNull();
    return row?.read(sum) ?? 0;
  }

  @override
  Stream<Map<String, double>> watchAllBalances() {
    final sum = _db.transactions.amount.sum();
    final query = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.itemId, sum])
      ..groupBy([_db.transactions.itemId]);
    return query.watch().map((rows) {
      return {
        for (final row in rows)
          row.read(_db.transactions.itemId)!: row.read(sum) ?? 0.0,
      };
    });
  }

  @override
  Future<void> addTransaction({
    required String itemId,
    required double amount,
    DateTime? date,
    String? note,
  }) async {
    final now = DateTime.now();
    final d = date ?? now;
    await _db.into(_db.transactions).insert(
      TransactionsCompanion.insert(
        id: _uuid.v4(),
        itemId: itemId,
        amount: amount,
        date: d,
        note: Value((note != null && note.isNotEmpty) ? note : null),
        createdAt: now,
      ),
    );
  }

  @override
  Future<void> updateTransaction(
    String id, {
    double? amount,
    DateTime? date,
    String? note,
  }) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        amount: amount != null ? Value(amount) : const Value.absent(),
        date: date != null ? Value(date) : const Value.absent(),
        note: note != null
            ? Value(note.isEmpty ? null : note)
            : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<VaultTransaction?> getTransaction(String id) async {
    final row =
        await (_db.select(_db.transactions)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : vaultTransactionFromRow(row);
  }
}
