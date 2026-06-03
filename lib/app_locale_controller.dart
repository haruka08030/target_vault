import 'package:flutter/material.dart';

import 'database/settings_store.dart';

/// アプリ表示言語。`locale == null` のときは端末の設定に従う。
class AppLocaleController extends ChangeNotifier {
  AppLocaleController(this._settings);

  final SettingsStore _settings;

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> initialize() async {
    final code = await _settings.getAppLocaleCode();
    _locale = _localeFromCode(code);
    notifyListeners();
  }

  Future<void> setLocaleCode(String? code) async {
    await _settings.setAppLocaleCode(code);
    _locale = _localeFromCode(code);
    notifyListeners();
  }

  /// 保存値: `null` / 空 / `system` → 端末に従う。`en` / `ja` のみ固定。
  static Locale? _localeFromCode(String? code) {
    if (code == null || code.isEmpty || code == 'system') return null;
    if (code == 'en' || code == 'ja') return Locale(code);
    return null;
  }
}
