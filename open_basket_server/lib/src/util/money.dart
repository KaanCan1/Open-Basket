/// Money helpers. Everything is an `int` in minor units — kuruş, cents, or
/// whole yen. No `double` anywhere near a price (rule 5).
abstract final class Money {
  /// How many minor units make one major unit, per ISO 4217.
  ///
  /// Only the currencies the picker offers are listed; anything else falls
  /// back to 2, which is right for the overwhelming majority. Zero-decimal
  /// currencies matter to us because the receipt gap has to split in whole
  /// units for them (ADR-008).
  static const _zeroDecimal = {'JPY', 'KRW', 'VND', 'CLP', 'ISK', 'XAF', 'XOF'};
  static const _threeDecimal = {'BHD', 'IQD', 'JOD', 'KWD', 'OMR', 'TND'};

  static int minorUnitDigits(String currencyCode) {
    final code = currencyCode.toUpperCase();
    if (_zeroDecimal.contains(code)) return 0;
    if (_threeDecimal.contains(code)) return 3;
    return 2;
  }

  /// Splits [totalMinor] evenly across [shareCount] people, giving the whole
  /// remainder to the person at [remainderIndex] — the shopper, so the
  /// settlement lines always add up to exactly what they paid (ADR-007).
  ///
  /// Works on minor units, so a zero-decimal currency naturally splits in
  /// whole units: there is nothing smaller to divide.
  ///
  /// Handles a negative total too. The till charging less than the items add up
  /// to is unusual but perfectly possible — a discount at the checkout, a
  /// mistyped price — and everyone's share is then a credit rather than a debt.
  static List<int> splitEvenly(
    int totalMinor,
    int shareCount, {
    required int remainderIndex,
  }) {
    if (shareCount <= 0) {
      throw ArgumentError.value(shareCount, 'shareCount', 'must be positive');
    }
    if (remainderIndex < 0 || remainderIndex >= shareCount) {
      throw ArgumentError.value(
        remainderIndex,
        'remainderIndex',
        'must be within 0..${shareCount - 1}',
      );
    }

    // Dart truncates towards zero, so -5 ~/ 4 is -1 and the remainder is -1
    // too. Both keep their sign, which is what we want: the shares stay on the
    // same side of zero as the total, and they still sum back to it.
    final share = totalMinor ~/ shareCount;
    final remainder = totalMinor - share * shareCount;

    return [
      for (var i = 0; i < shareCount; i++)
        i == remainderIndex ? share + remainder : share,
    ];
  }
}
