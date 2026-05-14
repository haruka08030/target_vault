import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// 目標金額などの数値入力に 3 桁カンマを付けるフォーマッター。
/// [decimalAllowed] が true のときは小数部 1 つまで許可（例: USD）。
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  ThousandsSeparatorInputFormatter({this.decimalAllowed = false});

  final bool decimalAllowed;

  static final NumberFormat _integerFormat = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String newText = newValue.text;
    if (newText.isEmpty) {
      return newValue;
    }

    String raw;
    String decimalPart = '';
    final hasDecimalPoint = decimalAllowed && newText.contains('.');
    if (hasDecimalPoint) {
      final parts = newText.split('.');
      raw = parts[0].replaceAll(RegExp(r'[^\d]'), '');
      final rawDec = parts.length > 1
          ? parts[1].replaceAll(RegExp(r'[^\d]'), '')
          : '';
      decimalPart = rawDec.length > 2 ? rawDec.substring(0, 2) : rawDec;
    } else {
      raw = newText.replaceAll(RegExp(r'[^\d]'), '');
    }

    if (!decimalAllowed && raw.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    if (decimalAllowed &&
        raw.isEmpty &&
        decimalPart.isEmpty &&
        !newText.startsWith('.')) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final intVal = raw.isEmpty ? 0 : (int.tryParse(raw) ?? 0);
    final intPartStr = _integerFormat.format(intVal);
    String formatted;
    if (decimalAllowed && (hasDecimalPoint || decimalPart.isNotEmpty)) {
      formatted = decimalPart.isEmpty
          ? '$intPartStr.'
          : '$intPartStr.$decimalPart';
    } else {
      formatted = intPartStr;
    }

    final cursor = newValue.selection.baseOffset.clamp(0, newText.length);
    final firstDot = newText.indexOf('.');
    final cursorPastDot = firstDot >= 0 && cursor > firstDot;

    var intDigits = 0;
    var fracDigits = 0;
    var dotSeen = false;
    for (var i = 0; i < cursor && i < newText.length; i++) {
      final c = newText[i];
      if (c == '.' && !dotSeen) {
        dotSeen = true;
      } else if (RegExp(r'\d').hasMatch(c)) {
        if (!dotSeen) {
          intDigits++;
        } else {
          fracDigits++;
        }
      }
    }

    final newOffset = _mapCursorInFormatted(
      formatted,
      intDigits,
      fracDigits,
      cursorPastDot,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newOffset.clamp(0, formatted.length),
      ),
    );
  }

  static int _countIntDigits(String intSection) {
    return intSection.replaceAll(RegExp(r'[^\d]'), '').length;
  }

  /// カーソルをカンマ付き整形後の文字列へ写像する。
  /// 末尾が「整数部.」だけのときもドットの右に置き、次の桁入力で小数が壊れないようにする。
  static int _mapCursorInFormatted(
    String formatted,
    int intDigits,
    int fracDigits,
    bool cursorPastDot,
  ) {
    final dotIdx = formatted.indexOf('.');
    if (dotIdx < 0) {
      return _offsetAfterIntDigits(formatted, intDigits);
    }

    final intSection = formatted.substring(0, dotIdx);
    final formattedIntDigits = _countIntDigits(intSection);
    var skipInt = intDigits;
    if (cursorPastDot && intDigits < formattedIntDigits) {
      skipInt = formattedIntDigits;
    }

    var i = 0;
    var consumedInt = 0;
    while (i < formatted.length && formatted[i] != '.') {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        consumedInt++;
        if (consumedInt == skipInt && !cursorPastDot && fracDigits == 0) {
          return i + 1;
        }
      }
      i++;
    }

    if (i >= formatted.length) {
      return formatted.length;
    }

    if (!cursorPastDot) {
      return i;
    }

    i++;
    var consumedFrac = 0;
    while (i < formatted.length && consumedFrac < fracDigits) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        consumedFrac++;
      }
      i++;
    }
    return i;
  }

  static int _offsetAfterIntDigits(String formatted, int digitTarget) {
    if (digitTarget <= 0) {
      return 0;
    }
    var count = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        count++;
        if (count >= digitTarget) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }
}
