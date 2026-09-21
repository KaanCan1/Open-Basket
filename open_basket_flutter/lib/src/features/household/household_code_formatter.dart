import 'package:flutter/services.dart';

/// Keeps the code field showing exactly what the server will read.
///
/// The code alphabet leaves out I, L and O but keeps 0 and 1, so someone
/// reading a code aloud says "oh" for a zero and "one" for a one and the
/// person typing gets it right either way. The server normalises the same way.
/// Doing it here as well is not duplication for its own sake: it means a code
/// that is going to be rejected never looks accepted.
class HouseholdCodeFormatter extends TextInputFormatter {
  const HouseholdCodeFormatter();

  static const alphabet = '0123456789ABCDEFGHJKMNPQRSTUVWXYZ';
  static const length = 6;

  /// Upper-cases, folds the letters the alphabet drops, and discards anything
  /// still outside it.
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.toUpperCase().runes) {
      final char = switch (String.fromCharCode(rune)) {
        'O' => '0',
        'I' || 'L' => '1',
        final other => other,
      };
      if (alphabet.contains(char)) buffer.write(char);
      if (buffer.length == length) break;
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = normalize(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
