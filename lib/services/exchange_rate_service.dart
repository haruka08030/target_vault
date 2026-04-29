import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/settings_store.dart';

class ExchangeRateService {
  ExchangeRateService(this._settings);

  final SettingsStore _settings;

  static const _apiUrl = 'https://api.frankfurter.app/latest';

  Future<Map<String, double>> fetchRates(String baseCurrency) async {
    try {
      final res = await http
          .get(Uri.parse('$_apiUrl?base=$baseCurrency&to=USD,JPY,EUR,GBP,CHF'))
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) return {};

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>?;
      if (rates == null) return {};

      final result = <String, double>{
        baseCurrency: 1.0,
        ...rates.map((k, v) => MapEntry(k, (v as num).toDouble())),
      };
      await _settings.setExchangeRates(result);
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<double> toBaseCurrency(double amount, String fromCurrency) async {
    final base = await _settings.getBaseCurrency();
    if (fromCurrency == base) return amount;

    var rates = await _settings.getExchangeRates();
    if (rates == null || rates.isEmpty || !rates.containsKey(fromCurrency)) {
      rates = await fetchRates(base);
    }
    if (rates.isEmpty || !rates.containsKey(fromCurrency)) return amount;

    final baseRate = rates[base] ?? 1.0;
    final fromRate = rates[fromCurrency] ?? 1.0;
    return amount * (baseRate / fromRate);
  }
}
