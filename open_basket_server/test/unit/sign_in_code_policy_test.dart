import 'package:open_basket_server/src/util/sign_in_code_policy.dart';
import 'package:test/test.dart';

void main() {
  group('generate', () {
    test('is always six digits', () {
      for (var i = 0; i < 2000; i++) {
        final code = SignInCodePolicy.generate();
        expect(code, hasLength(6));
        expect(RegExp(r'^\d{6}$').hasMatch(code), isTrue, reason: code);
      }
    });

    test('keeps its leading zeros', () {
      // 1000 in a million draws should turn up a code under 100000 often
      // enough; if padding were dropped these would come back short.
      final short = List.generate(
        2000,
        (_) => SignInCodePolicy.generate(),
      ).where((final c) => c.startsWith('0'));
      for (final code in short) {
        expect(code, hasLength(6));
      }
    });

    test('does not repeat itself the way a seeded Random would', () {
      final codes = List.generate(
        500,
        (_) => SignInCodePolicy.generate(),
      ).toSet();
      // Birthday collisions in 500 draws from a million are possible but a
      // handful at most. Anything below this means the source is not random.
      expect(codes.length, greaterThan(450));
    });
  });

  group('hash', () {
    const pepper = 'pepper';

    test('is stable for the same input', () {
      final a = SignInCodePolicy.hash(
        email: 'kaan@kaya.co',
        code: '407193',
        pepper: pepper,
      );
      final b = SignInCodePolicy.hash(
        email: 'kaan@kaya.co',
        code: '407193',
        pepper: pepper,
      );
      expect(a, b);
    });

    test('never stores the code itself', () {
      final hash = SignInCodePolicy.hash(
        email: 'kaan@kaya.co',
        code: '407193',
        pepper: pepper,
      );
      expect(hash, isNot(contains('407193')));
      expect(hash, hasLength(64));
    });

    test('binds the hash to the address', () {
      // A hash lifted from one row must not verify against another address.
      final mine = SignInCodePolicy.hash(
        email: 'kaan@kaya.co',
        code: '407193',
        pepper: pepper,
      );
      final theirs = SignInCodePolicy.hash(
        email: 'ayse@kaya.co',
        code: '407193',
        pepper: pepper,
      );
      expect(mine, isNot(theirs));
    });

    test('changes with the pepper', () {
      final a = SignInCodePolicy.hash(
        email: 'kaan@kaya.co',
        code: '407193',
        pepper: 'one',
      );
      final b = SignInCodePolicy.hash(
        email: 'kaan@kaya.co',
        code: '407193',
        pepper: 'two',
      );
      expect(a, isNot(b));
    });

    test('normalizes the address first, so case cannot fork an account', () {
      final typed = SignInCodePolicy.hash(
        email: '  Kaan@Kaya.CO ',
        code: '407193',
        pepper: pepper,
      );
      final stored = SignInCodePolicy.hash(
        email: 'kaan@kaya.co',
        code: '407193',
        pepper: pepper,
      );
      expect(typed, stored);
    });
  });

  group('hashesMatch', () {
    test('accepts equal hashes and rejects different ones', () {
      expect(SignInCodePolicy.hashesMatch('abc123', 'abc123'), isTrue);
      expect(SignInCodePolicy.hashesMatch('abc123', 'abc124'), isFalse);
      expect(SignInCodePolicy.hashesMatch('abc123', 'abc'), isFalse);
      expect(SignInCodePolicy.hashesMatch('', ''), isTrue);
    });

    test('a difference in the last character still fails', () {
      // The constant-time loop must not stop early on the first match.
      final a = 'f' * 63 + '0';
      final b = 'f' * 63 + '1';
      expect(SignInCodePolicy.hashesMatch(a, b), isFalse);
    });
  });

  group('normalizeEmail', () {
    test('trims and lowercases', () {
      expect(
        SignInCodePolicy.normalizeEmail('  Kaan@Kaya.CO '),
        'kaan@kaya.co',
      );
    });
  });

  group('looksLikeEmail', () {
    test('accepts ordinary addresses', () {
      expect(SignInCodePolicy.looksLikeEmail('kaan@kaya.co'), isTrue);
      expect(SignInCodePolicy.looksLikeEmail(' Ayse@Example.COM '), isTrue);
      expect(
        SignInCodePolicy.looksLikeEmail('a.b+tag@sub.example.com'),
        isTrue,
      );
    });

    test('rejects what cannot receive a code', () {
      expect(SignInCodePolicy.looksLikeEmail(''), isFalse);
      expect(SignInCodePolicy.looksLikeEmail('kaan'), isFalse);
      expect(SignInCodePolicy.looksLikeEmail('@kaya.co'), isFalse);
      expect(SignInCodePolicy.looksLikeEmail('kaan@'), isFalse);
      expect(SignInCodePolicy.looksLikeEmail('kaan@kaya'), isFalse);
      expect(SignInCodePolicy.looksLikeEmail('kaan@@kaya.co'), isFalse);
      expect(SignInCodePolicy.looksLikeEmail('kaan@.kaya.co'), isFalse);
      expect(SignInCodePolicy.looksLikeEmail('kaan@kaya.co.'), isFalse);
      expect(SignInCodePolicy.looksLikeEmail('kaan k@kaya.co'), isFalse);
      expect(SignInCodePolicy.looksLikeEmail('a@${'b' * 300}.co'), isFalse);
    });
  });

  group('normalizeCode', () {
    test('accepts six digits', () {
      expect(SignInCodePolicy.normalizeCode('407193'), '407193');
      expect(SignInCodePolicy.normalizeCode('000042'), '000042');
    });

    test('strips the spaces a paste brings with it', () {
      expect(SignInCodePolicy.normalizeCode(' 407 193 '), '407193');
    });

    test('refuses anything that is not six digits', () {
      expect(SignInCodePolicy.normalizeCode('40719'), isNull);
      expect(SignInCodePolicy.normalizeCode('4071933'), isNull);
      expect(SignInCodePolicy.normalizeCode('40719a'), isNull);
      expect(SignInCodePolicy.normalizeCode(''), isNull);
    });
  });
}
