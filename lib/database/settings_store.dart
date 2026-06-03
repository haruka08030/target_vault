import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

abstract class SettingsStore {
  Future<String> getBaseCurrency();

  Future<void> setBaseCurrency(String currency);

  Future<Map<String, double>?> getExchangeRates();

  Future<DateTime?> getExchangeRatesUpdatedAt();

  Future<void> setExchangeRates(Map<String, double> rates);

  Future<int?> getNotificationDay();

  Future<int?> getNotificationWeekday();

  Future<void> setNotificationDay(int? day);

  Future<void> setNotificationWeekday(int? weekday);

  Future<int> getNotificationHour();

  Future<int> getNotificationMinute();

  Future<void> setNotificationTime(int hour, int minute);

  /// 空・`system` は端末の言語。`en` / `ja` で固定。
  Future<String?> getAppLocaleCode();

  Future<void> setAppLocaleCode(String? code);
}

class DriftSettingsStore implements SettingsStore {
  DriftSettingsStore(this._db);

  final AppDatabase _db;

  static const _keyBaseCurrency = 'baseCurrency';
  static const _keyExchangeRates = 'exchangeRates';
  static const _keyNotificationDay = 'notificationDay';
  static const _keyNotificationWeekday = 'notificationWeekday';
  static const _keyNotificationHour = 'notificationHour';
  static const _keyNotificationMinute = 'notificationMinute';
  static const _keyAppLocale = 'appLocale';

  Future<String> _read(String key) async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value ?? '';
  }

  Future<void> _upsert(String key, String value) async {
    await _db.into(_db.settingsTable).insert(
      SettingsTableCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  @override
  Future<String> getBaseCurrency() async {
    final v = await _read(_keyBaseCurrency);
    return v.isEmpty ? 'JPY' : v;
  }

  @override
  Future<void> setBaseCurrency(String currency) async {
    await _upsert(_keyBaseCurrency, currency);
  }

  @override
  Future<Map<String, double>?> getExchangeRates() async {
    final raw = await _read(_keyExchangeRates);
    if (raw.isEmpty) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>?;
    return decoded?.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  @override
  Future<DateTime?> getExchangeRatesUpdatedAt() async {
    final raw = await _read('${_keyExchangeRates}_updated');
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> setExchangeRates(Map<String, double> rates) async {
    await _upsert(_keyExchangeRates, jsonEncode(rates));
    await _upsert(
      '${_keyExchangeRates}_updated',
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<int?> getNotificationDay() async {
    final v = await _read(_keyNotificationDay);
    return v.isEmpty ? null : int.tryParse(v);
  }

  @override
  Future<int?> getNotificationWeekday() async {
    final v = await _read(_keyNotificationWeekday);
    return v.isEmpty ? null : int.tryParse(v);
  }

  @override
  Future<void> setNotificationDay(int? day) async {
    if (day == null) {
      await (_db.delete(_db.settingsTable)
            ..where((t) => t.key.equals(_keyNotificationDay)))
          .go();
    } else {
      await _upsert(_keyNotificationDay, day.toString());
    }
  }

  @override
  Future<void> setNotificationWeekday(int? weekday) async {
    if (weekday == null) {
      await (_db.delete(_db.settingsTable)
            ..where((t) => t.key.equals(_keyNotificationWeekday)))
          .go();
    } else {
      await _upsert(_keyNotificationWeekday, weekday.toString());
    }
  }

  @override
  Future<int> getNotificationHour() async {
    final v = await _read(_keyNotificationHour);
    return v.isEmpty ? 20 : (int.tryParse(v) ?? 20);
  }

  @override
  Future<int> getNotificationMinute() async {
    final v = await _read(_keyNotificationMinute);
    return v.isEmpty ? 0 : (int.tryParse(v) ?? 0);
  }

  @override
  Future<void> setNotificationTime(int hour, int minute) async {
    await _upsert(_keyNotificationHour, hour.toString());
    await _upsert(_keyNotificationMinute, minute.toString());
  }

  @override
  Future<String?> getAppLocaleCode() async {
    final v = await _read(_keyAppLocale);
    if (v.isEmpty || v == 'system') return null;
    return v;
  }

  @override
  Future<void> setAppLocaleCode(String? code) async {
    if (code == null || code.isEmpty || code == 'system') {
      await (_db.delete(_db.settingsTable)
            ..where((t) => t.key.equals(_keyAppLocale)))
          .go();
    } else {
      await _upsert(_keyAppLocale, code);
    }
  }
}
