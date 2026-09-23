/// Names as the household sees them: on every item, and in "Ayşe owes Kaan".
abstract final class DisplayName {
  static const maxLength = 40;

  /// A first guess from an email address, until the person sets their own.
  ///
  /// The raw local part is what everybody saw before (ADR-041), and it is
  /// how "kaancan368368 owes ayse.kaya.1990" ended up on a settlement: the
  /// first word, without the digits people add to get a free address, with a
  /// capital. "ayse.kaya" → "Ayse", "kaancan368368" → "Kaancan", "m_ert" →
  /// "M". Anything that leaves nothing falls back to "Member".
  static String fromEmail(String? email) {
    if (email == null || !email.contains('@')) return 'Member';
    final local = email.substring(0, email.indexOf('@'));
    for (final word in local.split(RegExp(r'[._+\-]'))) {
      final letters = word.replaceAll(RegExp(r'[0-9]'), '');
      if (letters.isNotEmpty) {
        final name = letters.length > maxLength
            ? letters.substring(0, maxLength)
            : letters;
        return name[0].toUpperCase() + name.substring(1);
      }
    }
    return 'Member';
  }

  /// Trimmed, inner runs of whitespace collapsed, 1 to [maxLength]
  /// characters; null when that leaves nothing usable.
  static String? clean(String name) {
    final collapsed = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (collapsed.isEmpty || collapsed.length > maxLength) return null;
    return collapsed;
  }
}
