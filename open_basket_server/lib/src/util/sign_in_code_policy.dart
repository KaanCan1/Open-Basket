import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// The six-digit sign-in code (ADR-004), and nothing that needs a database.
///
/// Kept separate from the service so the parts that are easy to get subtly
/// wrong — the hashing, the comparison, the normalisation — can be tested on
/// their own.
abstract final class SignInCodePolicy {
  /// How long a code stays usable.
  static const lifetime = Duration(minutes: 10);

  /// How many wrong guesses a single code survives. The fourth burns it.
  static const maxAttempts = 3;

  /// How long before a new code can be asked for. The design shows this as a
  /// countdown on the resend button; the server is what actually enforces it.
  static const resendCooldown = Duration(seconds: 24);

  static const _length = 6;

  /// `Random.secure()` rather than `Random()`: a predictable code is a way into
  /// somebody else's household.
  static final _random = Random.secure();

  /// Six digits, zero-padded, so `000042` is a perfectly good code and the
  /// space is the full million.
  static String generate() =>
      _random.nextInt(1000000).toString().padLeft(_length, '0');

  /// Codes are only ever stored hashed.
  ///
  /// The email is mixed in so a hash lifted from one row cannot be replayed
  /// against another address, and the pepper means a leaked table is not a
  /// rainbow table away from a million six-digit codes.
  static String hash({
    required String email,
    required String code,
    required String pepper,
  }) {
    final input = utf8.encode('${normalizeEmail(email)}|$code|$pepper');
    return sha256.convert(input).toString();
  }

  /// Compares in constant time.
  ///
  /// A short-circuiting `==` leaks how many leading characters were right, and
  /// with only a million possibilities that is worth closing even though the
  /// attempt limit already makes guessing impractical.
  static bool hashesMatch(String a, String b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return difference == 0;
  }

  /// One spelling per address, so "Kaan@Kaya.co " and "kaan@kaya.co" are the
  /// same person and cannot end up with two accounts.
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  /// Cheap shape check before anything touches the database. Deliberately not
  /// a full RFC 5322 parse — the code that follows is the real proof that the
  /// address exists, since it has to arrive there to be typed back.
  static bool looksLikeEmail(String email) {
    final value = normalizeEmail(email);
    if (value.length < 3 || value.length > 254) return false;
    final at = value.indexOf('@');
    if (at <= 0 || at != value.lastIndexOf('@')) return false;
    final domain = value.substring(at + 1);
    return domain.contains('.') &&
        !domain.startsWith('.') &&
        !domain.endsWith('.') &&
        !value.contains(' ');
  }

  /// Accepts what the user typed as a code, or null if it cannot be one.
  /// Strips spaces, because a pasted code often brings them along.
  static String? normalizeCode(String code) {
    final value = code.replaceAll(RegExp(r'\s'), '');
    if (value.length != _length) return null;
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return null;
    return value;
  }
}
