import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Stream<List<Transaction>> watchByItem(String itemId) =>
      (_db.select(_db.transactions)
            ..where((t) => t.itemId.equals(itemId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<double> getCurrentAmount(String itemId) async {
    final rows = await (_db.select(_db.transactions)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return rows.fold<double>(0, (s, t) => s + t.amount);
  }

  Future<void> addTransaction({
    required String itemId,
    required double amount,
    DateTime? date,
  }) async {
    final now = DateTime.now();
    final d = date ?? now;
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: _uuid.v4(),
            itemId: itemId,
            amount: amount,
            date: d,
            createdAt: now,
          ),
        );
  }

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
            note: note != null ? Value(note) : const Value.absent(),
          ),
        );
  }

  Future<void> deleteTransaction(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<Transaction?> getTransaction(String id) =>
      (_db.select(_db.transactions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
}
