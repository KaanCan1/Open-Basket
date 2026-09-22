import 'package:intl/intl.dart';

/// Money on screen. Amounts arrive as `int` minor units (rule 5) and leave as
/// `int` minor units; a `double` never holds a price, not even on the way
/// through a text field.
///
/// Formatting follows the basket's currency, not the phone's locale: a
/// Turkish household sees ₺84.50 on an English phone and the same on a German
/// one, because the design set and the settlement copy use that form.
abstract final class MoneyFormat {
  // The server has the same table in `util/money.dart`. The generated client
  // cannot share code, so it is repeated here; the two only have to agree on
  // the currencies the picker offers.
  static const _zeroDecimal = {'JPY', 'KRW', 'VND', 'CLP', 'ISK', 'XAF', 'XOF'};
  static const _threeDecimal = {'BHD', 'IQD', 'JOD', 'KWD', 'OMR', 'TND'};

  static int minorUnitDigits(String currencyCode) {
    final code = currencyCode.toUpperCase();
    if (_zeroDecimal.contains(code)) return 0;
    if (_threeDecimal.contains(code)) return 3;
    return 2;
  }

  /// `₺84.50`, `$1,204.00`, `¥1,003`.
  static String format(int minor, String currencyCode) {
    final digits = minorUnitDigits(currencyCode);
    final format = NumberFormat.simpleCurrency(
      locale: 'en',
      name: currencyCode.toUpperCase(),
      decimalDigits: digits,
    );
    return format.format(_toMajor(minor, digits));
  }

  /// The currency's symbol on its own, for the prefix of a price field.
  static String symbol(String currencyCode) => NumberFormat.simpleCurrency(
    locale: 'en',
    name: currencyCode.toUpperCase(),
  ).currencySymbol;

  /// The amount as it sits in a price field: no symbol, no grouping, so what
  /// the shopper sees is what they can edit. `84.50`, `1003`.
  static String plain(int minor, String currencyCode) {
    final digits = minorUnitDigits(currencyCode);
    if (digits == 0) return '$minor';
    final sign = minor < 0 ? '-' : '';
    final abs = minor.abs().toString().padLeft(digits + 1, '0');
    final cut = abs.length - digits;
    return '$sign${abs.substring(0, cut)}.${abs.substring(cut)}';
  }

  /// What the shopper typed, in minor units, or null when it is not a price.
  ///
  /// Takes a comma as the decimal mark as well as a point, because a Turkish
  /// keyboard offers the comma and people type what their receipt says. Done
  /// on the digits as a string, never through `double.parse`, so 0.1 + 0.2
  /// never gets a say in what anybody owes.
  static int? parse(String text, String currencyCode) {
    final digits = minorUnitDigits(currencyCode);
    final cleaned = text.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    final match = RegExp(r'^(\d+)(?:\.(\d*))?$').firstMatch(cleaned);
    if (match == null) return null;
    final whole = match.group(1)!;
    final fraction = match.group(2) ?? '';
    if (fraction.length > digits) return null;
    final minor = int.tryParse(whole + fraction.padRight(digits, '0'));
    return minor;
  }

  // Only ever used to hand intl a number to lay out; nothing is computed on
  // the result.
  static num _toMajor(int minor, int digits) {
    if (digits == 0) return minor;
    var divisor = 1;
    for (var i = 0; i < digits; i++) {
      divisor *= 10;
    }
    return minor / divisor;
  }
}
