import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class ItemRepository {
  ItemRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Stream<List<Item>> watchAllItems() =>
      (_db.select(_db.items)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  Future<Item?> getItem(String id) =>
      (_db.select(_db.items)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> createItem({
    required String title,
    required double targetAmount,
    String? currency,
    String? imagePath,
    DateTime? targetDate,
    String? category,
  }) async {
    final now = DateTime.now();
    await _db.into(_db.items).insert(
          ItemsCompanion.insert(
            id: _uuid.v4(),
            title: title,
            targetAmount: targetAmount,
            currency: Value(currency ?? 'JPY'),
            imagePath: Value(imagePath),
            targetDate: Value(targetDate),
            category: Value(category),
            status: ItemStatus.saving,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> updateItem(
    String id, {
    String? title,
    double? targetAmount,
    String? currency,
    Value<String?>? imagePath,
    DateTime? targetDate,
    String? category,
  }) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
          ItemsCompanion(
            title: title != null ? Value(title) : const Value.absent(),
            targetAmount:
                targetAmount != null ? Value(targetAmount) : const Value.absent(),
            currency: currency != null ? Value(currency) : const Value.absent(),
            imagePath: imagePath ?? const Value.absent(),
            targetDate:
                targetDate != null ? Value(targetDate) : const Value.absent(),
            category: category != null ? Value(category) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> updateItemStatus(String id, ItemStatus status) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
          ItemsCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteItem(String id) async {
    await (_db.delete(_db.items)..where((t) => t.id.equals(id))).go();
  }
}
