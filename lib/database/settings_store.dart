import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

class SettingsStore {
  SettingsStore(this._db);

  final AppDatabase _db;

  static const _keyBaseCurrency = 'baseCurrency';
  static const _keyExchangeRates = 'exchangeRates';
  static const _keyNotificationDay = 'notificationDay';
  static const _keyNotificationWeekday = 'notificationWeekday';
  static const _keyNotificationHour = 'notificationHour';
  static const _keyNotificationMinute = 'notificationMinute';

  Future<String> getBaseCurrency() async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.key.equals(_keyBaseCurrency)))
        .getSingleOrNull();
    return row?.value ?? 'JPY';
  }

  Future<void> setBaseCurrency(String currency) async {
    await _db.into(_db.settingsTable).insert(
          SettingsTableCompanion.insert(
            key: _keyBaseCurrency,
            value: currency,
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<Map<String, double>?> getExchangeRates() async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.key.equals(_keyExchangeRates)))
        .getSingleOrNull();
    if (row == null) return null;
    final decoded = jsonDecode(row.value) as Map<String, dynamic>?;
    return decoded?.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<DateTime?> getExchangeRatesUpdatedAt() async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.key.equals('${_keyExchangeRates}_updated')))
        .getSingleOrNull();
    if (row == null) return null;
    return DateTime.tryParse(row.value);
  }

  Future<void> setExchangeRates(Map<String, double> rates) async {
    await _db.into(_db.settingsTable).insert(
          SettingsTableCompanion.insert(
            key: _keyExchangeRates,
            value: jsonEncode(rates),
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _db.into(_db.settingsTable).insert(
          SettingsTableCompanion.insert(
            key: '${_keyExchangeRates}_updated',
            value: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<int?> getNotificationDay() async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.key.equals(_keyNotificationDay)))
        .getSingleOrNull();
    return row != null ? int.tryParse(row.value) : null;
  }

  Future<int?> getNotificationWeekday() async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.key.equals(_keyNotificationWeekday)))
        .getSingleOrNull();
    return row != null ? int.tryParse(row.value) : null;
  }

  Future<void> setNotificationDay(int? day) async {
    if (day == null) {
      await (_db.delete(_db.settingsTable)
            ..where((t) => t.key.equals(_keyNotificationDay)))
          .go();
    } else {
      await _db.into(_db.settingsTable).insert(
            SettingsTableCompanion.insert(
              key: _keyNotificationDay,
              value: day.toString(),
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<void> setNotificationWeekday(int? weekday) async {
    if (weekday == null) {
      await (_db.delete(_db.settingsTable)
            ..where((t) => t.key.equals(_keyNotificationWeekday)))
          .go();
    } else {
      await _db.into(_db.settingsTable).insert(
            SettingsTableCompanion.insert(
              key: _keyNotificationWeekday,
              value: weekday.toString(),
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<int> getNotificationHour() async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.key.equals(_keyNotificationHour)))
        .getSingleOrNull();
    return row != null ? int.tryParse(row.value) ?? 20 : 20;
  }

  Future<int> getNotificationMinute() async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.key.equals(_keyNotificationMinute)))
        .getSingleOrNull();
    return row != null ? int.tryParse(row.value) ?? 0 : 0;
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    await _db.into(_db.settingsTable).insert(
          SettingsTableCompanion.insert(
            key: _keyNotificationHour,
            value: hour.toString(),
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _db.into(_db.settingsTable).insert(
          SettingsTableCompanion.insert(
            key: _keyNotificationMinute,
            value: minute.toString(),
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}
