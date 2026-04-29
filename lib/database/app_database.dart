import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'target_vault.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
