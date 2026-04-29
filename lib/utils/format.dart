import 'package:intl/intl.dart';

final _currencyFormatJPY = NumberFormat.currency(
  locale: 'ja_JP',
  symbol: '',
  decimalDigits: 0,
);

final _currencyFormatDecimal = NumberFormat.currency(
  locale: 'en_US',
  symbol: '',
  decimalDigits: 2,
);

String formatCurrency(
  double amount, {
  String symbol = '¥',
  bool showSymbol = true,
}) {
  if (showSymbol) {
    return '$symbol${_currencyFormatJPY.format(amount)}';
  }
  return _currencyFormatJPY.format(amount);
}

int _decimalDigitsFor(String code) {
  return code == 'JPY' ? 0 : 2;
}

String formatCurrencyByCode(double amount, String currencyCode) {
  final symbols = <String, String>{
    'JPY': '¥',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'CHF': 'CHF ',
  };
  final decimals = _decimalDigitsFor(currencyCode);
  final fmt = decimals > 0 ? _currencyFormatDecimal : _currencyFormatJPY;
  final symbol = symbols[currencyCode] ?? '$currencyCode ';
  return '$symbol${fmt.format(amount)}';
}
