import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'database_connection.dart';
import 'memory_test_executor.dart';

part 'app_database.g.dart';

enum ItemStatus {
  saving,
  repaying,
  completed;

  String get dbValue => name;
  static ItemStatus fromDb(String value) => ItemStatus.values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => ItemStatus.saving,
  );
}

class ItemStatusConverter extends TypeConverter<ItemStatus, String> {
  @override
  ItemStatus fromSql(String fromDb) => ItemStatus.fromDb(fromDb);
  @override
  String toSql(ItemStatus value) => value.dbValue;
}

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get targetAmount => real()();
  TextColumn get currency => text().withDefault(const Constant('JPY'))();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get status => text().map(ItemStatusConverter())();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Items, Transactions, SettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connectAppDatabaseExecutor());

  /// メモリ SQLite。Widget テスト用（ストリームを同期的に閉じる）。
  @visibleForTesting
  AppDatabase.memoryForTests() : super(memoryTestExecutor());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(items, items.sortOrder);
      }
    },
  );
}
