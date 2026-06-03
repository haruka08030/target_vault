import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/utils/thousands_separator_input_formatter.dart';

void main() {
  group('ThousandsSeparatorInputFormatter decimal', () {
    test('cursor stays after dot when typing 1.', () {
      final f = ThousandsSeparatorInputFormatter(decimalAllowed: true);
      var v = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      v = f.formatEditUpdate(
        v,
        const TextEditingValue(
          text: '1',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      expect(v.text, '1');
      v = f.formatEditUpdate(
        v,
        const TextEditingValue(
          text: '1.',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      expect(v.text, '1.');
      expect(
        v.selection.baseOffset,
        2,
        reason: 'cursor should be after trailing decimal point',
      );
    });

    test('cursor after dot for 12.', () {
      final f = ThousandsSeparatorInputFormatter(decimalAllowed: true);
      var v = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      for (final step in [
        const TextEditingValue(
          text: '12',
          selection: TextSelection.collapsed(offset: 2),
        ),
        const TextEditingValue(
          text: '12.',
          selection: TextSelection.collapsed(offset: 3),
        ),
      ]) {
        v = f.formatEditUpdate(v, step);
      }
      expect(v.text, '12.');
      expect(v.selection.baseOffset, 3);
    });

    test('thousands with trailing dot', () {
      final f = ThousandsSeparatorInputFormatter(decimalAllowed: true);
      var v = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      v = f.formatEditUpdate(
        v,
        const TextEditingValue(
          text: '1000.',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(v.text, '1,000.');
      expect(v.selection.baseOffset, v.text.length);
    });
  });
}
