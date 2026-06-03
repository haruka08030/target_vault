import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/utils/format.dart';

void main() {
  group('formatCurrency', () {
    test('formats positive amount with symbol by default', () {
      expect(formatCurrency(1000), '¥1,000');
      expect(formatCurrency(1234567), '¥1,234,567');
    });

    test('formats with showSymbol false', () {
      expect(formatCurrency(1000, showSymbol: false), '1,000');
    });

    test('uses custom symbol', () {
      expect(formatCurrency(1000, symbol: '\$'), '\$1,000');
    });

    test('formats zero', () {
      expect(formatCurrency(0), '¥0');
    });

    test('formats decimal as integer for JPY', () {
      expect(formatCurrency(1000.5), '¥1,001');
    });
  });

  group('formatCurrencyByCode', () {
    test('JPY uses no decimal places', () {
      expect(formatCurrencyByCode(1000, 'JPY'), '¥1,000');
      expect(formatCurrencyByCode(1000.99, 'JPY'), '¥1,001');
    });

    test('USD uses 2 decimal places', () {
      expect(formatCurrencyByCode(10.5, 'USD'), '\$10.50');
    });

    test('EUR uses 2 decimal places', () {
      expect(formatCurrencyByCode(99.99, 'EUR'), '€99.99');
    });

    test('GBP and CHF have correct symbols', () {
      expect(formatCurrencyByCode(1, 'GBP'), '£1.00');
      expect(formatCurrencyByCode(1, 'CHF'), 'CHF 1.00');
    });

    test('unknown code uses code as prefix', () {
      expect(formatCurrencyByCode(1, 'XXX'), 'XXX 1.00');
    });
  });
}
