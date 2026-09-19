import 'dart:math';

/// The permanent six-character household code (ADR-006).
///
/// No expiry: it works until an owner rotates it, and rotating kills the old
/// one the same instant.
abstract final class HouseholdCode {
  static const length = 6;

  /// Digits plus letters, minus the three that get misread when somebody types
  /// a code off a phone screen: `I` and `L` (for `1`), and `O` (for `0`).
  ///
  /// Zero and one stay in. The design's own error copy leans on exactly this —
  /// "codes never contain the letter O, only the digit zero" — so the alphabet
  /// and the message have to agree, or the hint is a lie.
  static const alphabet = '0123456789ABCDEFGHJKMNPQRSTUVWXYZ';

  static final _random = Random.secure();

  /// `Random.secure()` rather than `Random()`: a guessable code is a way into
  /// somebody else's household, and the space here is only 33^6.
  static String generate() => String.fromCharCodes([
    for (var i = 0; i < length; i++)
      alphabet.codeUnitAt(_random.nextInt(alphabet.length)),
  ]);

  /// What the user typed, in the form the database stores.
  ///
  /// Upper-cases, drops spaces and dashes — people space codes out when they
  /// read them aloud — and forgives the two confusions the alphabet already
  /// avoids, so typing `O` where the code has `0` still gets you in rather
  /// than sending you back to ask for the code again.
  static String normalize(String code) {
    final cleaned = code
        .toUpperCase()
        .replaceAll(RegExp(r'[\s\-]'), '')
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('L', '1');
    return cleaned;
  }

  /// Whether [code] could be a household code at all. Cheap enough to run
  /// before touching the database.
  static bool isWellFormed(String code) {
    final value = normalize(code);
    if (value.length != length) return false;
    return value.split('').every(alphabet.contains);
  }
}
