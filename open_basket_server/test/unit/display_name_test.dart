import 'package:open_basket_server/src/util/display_name.dart';
import 'package:test/test.dart';

void main() {
  group('a first guess from the email', () {
    test('takes the first word, capitalised, without the digits', () {
      expect(DisplayName.fromEmail('kaancan368368@gmail.com'), 'Kaancan');
      expect(DisplayName.fromEmail('ayse.kaya@example.com'), 'Ayse');
      expect(DisplayName.fromEmail('mert_1990@example.com'), 'Mert');
      expect(DisplayName.fromEmail('jin+shop@example.com'), 'Jin');
    });

    test('skips a word that was only digits', () {
      expect(DisplayName.fromEmail('1990.selin@example.com'), 'Selin');
    });

    test('keeps letters outside ASCII', () {
      expect(DisplayName.fromEmail('şule@example.com'), 'Şule');
    });

    test('falls back when nothing is left', () {
      expect(DisplayName.fromEmail('12345@example.com'), 'Member');
      expect(DisplayName.fromEmail(null), 'Member');
      expect(DisplayName.fromEmail('not-an-address'), 'Member');
    });
  });

  group('a name someone types', () {
    test('is trimmed and its spaces collapsed', () {
      expect(DisplayName.clean('  Ayşe   Kaya '), 'Ayşe Kaya');
    });

    test('must leave something, and not too much', () {
      expect(DisplayName.clean('   '), isNull);
      expect(DisplayName.clean('a' * 41), isNull);
      expect(DisplayName.clean('a' * 40), 'a' * 40);
    });
  });
}
