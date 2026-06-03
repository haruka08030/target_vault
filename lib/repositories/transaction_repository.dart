import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/vault_mappers.dart';
import '../models/vault_transaction.dart';

abstract class TransactionRepository {
  Stream<List<VaultTransaction>> watchByItem(String itemId);

  Future<double> getCurrentAmount(String itemId);

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
    final rows = await (_db.select(_db.transactions)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return rows.fold<double>(0, (s, t) => s + t.amount);
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
