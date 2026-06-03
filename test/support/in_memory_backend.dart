import 'dart:async';
import 'dart:convert';

import 'package:target_vault/database/settings_store.dart';
import 'package:target_vault/models/item_status.dart';
import 'package:target_vault/models/vault_item.dart';
import 'package:target_vault/models/vault_transaction.dart';
import 'package:target_vault/repositories/item_repository.dart';
import 'package:target_vault/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class MemorySettingsStore extends SettingsStore {
  final _map = <String, String>{};

  static const _keyBaseCurrency = 'baseCurrency';
  static const _keyExchangeRates = 'exchangeRates';
  static const _keyNotificationDay = 'notificationDay';
  static const _keyNotificationWeekday = 'notificationWeekday';
  static const _keyNotificationHour = 'notificationHour';
  static const _keyNotificationMinute = 'notificationMinute';
  static const _keyAppLocale = 'appLocale';

  @override
  Future<String> getBaseCurrency() async =>
      _map[_keyBaseCurrency] ?? 'JPY';

  @override
  Future<void> setBaseCurrency(String currency) async {
    _map[_keyBaseCurrency] = currency;
  }

  @override
  Future<Map<String, double>?> getExchangeRates() async {
    final raw = _map[_keyExchangeRates];
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>?;
    return decoded?.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  @override
  Future<DateTime?> getExchangeRatesUpdatedAt() async {
    final v = _map['${_keyExchangeRates}_updated'];
    if (v == null) return null;
    return DateTime.tryParse(v);
  }

  @override
  Future<void> setExchangeRates(Map<String, double> rates) async {
    _map[_keyExchangeRates] = jsonEncode(rates);
    _map['${_keyExchangeRates}_updated'] =
        DateTime.now().toUtc().toIso8601String();
  }

  @override
  Future<int?> getNotificationDay() async {
    final v = _map[_keyNotificationDay];
    return v != null ? int.tryParse(v) : null;
  }

  @override
  Future<int?> getNotificationWeekday() async {
    final v = _map[_keyNotificationWeekday];
    return v != null ? int.tryParse(v) : null;
  }

  @override
  Future<void> setNotificationDay(int? day) async {
    if (day == null) {
      _map.remove(_keyNotificationDay);
    } else {
      _map[_keyNotificationDay] = day.toString();
    }
  }

  @override
  Future<void> setNotificationWeekday(int? weekday) async {
    if (weekday == null) {
      _map.remove(_keyNotificationWeekday);
    } else {
      _map[_keyNotificationWeekday] = weekday.toString();
    }
  }

  @override
  Future<int> getNotificationHour() async {
    final v = _map[_keyNotificationHour];
    return v != null ? int.tryParse(v) ?? 20 : 20;
  }

  @override
  Future<int> getNotificationMinute() async {
    final v = _map[_keyNotificationMinute];
    return v != null ? int.tryParse(v) ?? 0 : 0;
  }

  @override
  Future<void> setNotificationTime(int hour, int minute) async {
    _map[_keyNotificationHour] = hour.toString();
    _map[_keyNotificationMinute] = minute.toString();
  }

  @override
  Future<String?> getAppLocaleCode() async {
    final v = _map[_keyAppLocale];
    if (v == null || v.isEmpty || v == 'system') return null;
    return v;
  }

  @override
  Future<void> setAppLocaleCode(String? code) async {
    if (code == null || code.isEmpty || code == 'system') {
      _map.remove(_keyAppLocale);
    } else {
      _map[_keyAppLocale] = code;
    }
  }
}

/// Shared in-memory state for [FakeItemRepository] and [FakeTransactionRepository].
class ItemTxTestBackend {
  final List<VaultItem> items = [];
  final Map<String, List<VaultTransaction>> txsByItem = {};
  final _uuid = const Uuid();
  final _itemsCtrl = StreamController<List<VaultItem>>.broadcast();
  final _txCtrls = <String, StreamController<List<VaultTransaction>>>{};

  void _emitItems() {
    if (!_itemsCtrl.isClosed) {
      _itemsCtrl.add(List.unmodifiable(items));
    }
  }

  void _emitTx(String itemId) {
    final c = _txCtrls[itemId];
    if (c != null && !c.isClosed) {
      c.add(List.unmodifiable(txsByItem[itemId] ?? const []));
    }
  }

  Stream<List<VaultItem>> watchItems() {
    return Stream<List<VaultItem>>.multi((emitter) {
      emitter.add(List.unmodifiable(items));
      final sub = _itemsCtrl.stream.listen(emitter.add);
      emitter.onCancel = sub.cancel;
    });
  }

  Stream<List<VaultTransaction>> watchTx(String itemId) {
    final c = _txCtrls.putIfAbsent(
      itemId,
      () => StreamController<List<VaultTransaction>>.broadcast(),
    );
    return Stream<List<VaultTransaction>>.multi((emitter) {
      emitter.add(List.unmodifiable(txsByItem[itemId] ?? const []));
      final sub = c.stream.listen(emitter.add);
      emitter.onCancel = sub.cancel;
    });
  }

  void dispose() {
    _itemsCtrl.close();
    for (final c in _txCtrls.values) {
      c.close();
    }
  }
}

class FakeItemRepository implements ItemRepository {
  FakeItemRepository(this._b);

  final ItemTxTestBackend _b;

  @override
  Stream<List<VaultItem>> watchAllItems() => _b.watchItems();

  @override
  Future<VaultItem?> getItem(String id) async {
    try {
      return _b.items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
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
    final now = DateTime.now().toUtc();
    final id = _b._uuid.v4();
    final nextOrder = _b.items.isEmpty
        ? 0
        : (_b.items.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) +
              1);
    final status = purchasedOnCredit ? ItemStatus.repaying : ItemStatus.saving;
    final item = VaultItem(
      id: id,
      title: title,
      targetAmount: targetAmount,
      currency: currency ?? 'JPY',
      imagePath: imagePath,
      targetDate: targetDate,
      category: category,
      status: status,
      sortOrder: nextOrder,
      createdAt: now,
      updatedAt: now,
    );
    _b.items.add(item);
    if (purchasedOnCredit) {
      _b.txsByItem[id] = [
        VaultTransaction(
          id: _b._uuid.v4(),
          itemId: id,
          amount: -targetAmount,
          date: now,
          note: '追加時: 前借りで購入済み',
          createdAt: now,
        ),
      ];
      _b._emitTx(id);
    }
    _b._emitItems();
  }

  @override
  Future<bool> convertSavingItemToRepayingOnCredit(
    String itemId, {
    required double targetAmount,
  }) async {
    final item = await getItem(itemId);
    if (item == null || item.status != ItemStatus.saving) return false;
    final now = DateTime.now().toUtc();
    final list = _b.txsByItem.putIfAbsent(itemId, () => []);
    list.add(
      VaultTransaction(
        id: _b._uuid.v4(),
        itemId: itemId,
        amount: -targetAmount,
        date: now,
        note: '編集: 前借りで購入済みとして登録',
        createdAt: now,
      ),
    );
    final idx = _b.items.indexWhere((e) => e.id == itemId);
    if (idx >= 0) {
      final old = _b.items[idx];
      _b.items[idx] = VaultItem(
        id: old.id,
        title: old.title,
        targetAmount: old.targetAmount,
        currency: old.currency,
        imagePath: old.imagePath,
        targetDate: old.targetDate,
        category: old.category,
        status: ItemStatus.repaying,
        sortOrder: old.sortOrder,
        createdAt: old.createdAt,
        updatedAt: now,
      );
    }
    _b._emitTx(itemId);
    _b._emitItems();
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
    final idx = _b.items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final now = DateTime.now().toUtc();
    final old = _b.items[idx];
    _b.items[idx] = VaultItem(
      id: old.id,
      title: title,
      targetAmount: targetAmount,
      currency: currency,
      imagePath: imagePath,
      targetDate: targetDate,
      category: category,
      status: old.status,
      sortOrder: old.sortOrder,
      createdAt: old.createdAt,
      updatedAt: now,
    );
    _b._emitItems();
  }

  @override
  Future<void> updateItemStatus(String id, ItemStatus status) async {
    final idx = _b.items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final now = DateTime.now().toUtc();
    final old = _b.items[idx];
    _b.items[idx] = VaultItem(
      id: old.id,
      title: old.title,
      targetAmount: old.targetAmount,
      currency: old.currency,
      imagePath: old.imagePath,
      targetDate: old.targetDate,
      category: old.category,
      status: status,
      sortOrder: old.sortOrder,
      createdAt: old.createdAt,
      updatedAt: now,
    );
    _b._emitItems();
  }

  @override
  Future<void> deleteItem(String id) async {
    _b.items.removeWhere((e) => e.id == id);
    _b.txsByItem.remove(id);
    _b._emitItems();
    _b._emitTx(id);
  }

  @override
  Future<void> updateItemsOrder(List<String> orderedIds) async {
    final now = DateTime.now().toUtc();
    for (var i = 0; i < orderedIds.length; i++) {
      final idx = _b.items.indexWhere((e) => e.id == orderedIds[i]);
      if (idx < 0) continue;
      final old = _b.items[idx];
      _b.items[idx] = VaultItem(
        id: old.id,
        title: old.title,
        targetAmount: old.targetAmount,
        currency: old.currency,
        imagePath: old.imagePath,
        targetDate: old.targetDate,
        category: old.category,
        status: old.status,
        sortOrder: i,
        createdAt: old.createdAt,
        updatedAt: now,
      );
    }
    _b._emitItems();
  }
}

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository(this._b);

  final ItemTxTestBackend _b;

  @override
  Stream<List<VaultTransaction>> watchByItem(String itemId) =>
      _b.watchTx(itemId);

  @override
  Future<double> getCurrentAmount(String itemId) async {
    final list = _b.txsByItem[itemId] ?? const [];
    return list.fold<double>(0, (s, t) => s + t.amount);
  }

  @override
  Future<void> addTransaction({
    required String itemId,
    required double amount,
    DateTime? date,
    String? note,
  }) async {
    final now = DateTime.now().toUtc();
    final d = date ?? now;
    final list = _b.txsByItem.putIfAbsent(itemId, () => []);
    list.add(
      VaultTransaction(
        id: _b._uuid.v4(),
        itemId: itemId,
        amount: amount,
        date: d,
        note: (note != null && note.isNotEmpty) ? note : null,
        createdAt: now,
      ),
    );
    _b._emitTx(itemId);
  }

  @override
  Future<void> updateTransaction(
    String id, {
    double? amount,
    DateTime? date,
    String? note,
  }) async {
    for (final entry in _b.txsByItem.entries) {
      final idx = entry.value.indexWhere((t) => t.id == id);
      if (idx >= 0) {
        final t = entry.value[idx];
        entry.value[idx] = VaultTransaction(
          id: t.id,
          itemId: t.itemId,
          amount: amount ?? t.amount,
          date: date ?? t.date,
          note: note != null ? (note.isEmpty ? null : note) : t.note,
          createdAt: t.createdAt,
        );
        _b._emitTx(entry.key);
        return;
      }
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    for (final entry in _b.txsByItem.entries) {
      entry.value.removeWhere((t) => t.id == id);
      _b._emitTx(entry.key);
    }
  }

  @override
  Future<VaultTransaction?> getTransaction(String id) async {
    for (final list in _b.txsByItem.values) {
      for (final t in list) {
        if (t.id == id) return t;
      }
    }
    return null;
  }
}
