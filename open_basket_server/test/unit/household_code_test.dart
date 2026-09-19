import 'package:open_basket_server/src/util/household_code.dart';
import 'package:test/test.dart';

void main() {
  group('generate', () {
    test('is always six characters from the alphabet', () {
      for (var i = 0; i < 2000; i++) {
        final code = HouseholdCode.generate();
        expect(code, hasLength(6));
        expect(
          code.split('').every(HouseholdCode.alphabet.contains),
          isTrue,
          reason: code,
        );
      }
    });

    test('never emits the characters people misread', () {
      // The design's error copy promises this: "codes never contain the letter
      // O, only the digit zero". If the alphabet drifts, the hint becomes a lie.
      final codes = List.generate(3000, (_) => HouseholdCode.generate());
      for (final forbidden in ['O', 'I', 'L']) {
        expect(
          codes.any((final c) => c.contains(forbidden)),
          isFalse,
          reason: 'found $forbidden in a generated code',
        );
      }
    });

    test('does not repeat itself the way a seeded Random would', () {
      final codes = List.generate(500, (_) => HouseholdCode.generate()).toSet();
      expect(codes.length, greaterThan(495));
    });
  });

  group('normalize', () {
    test('upper-cases', () {
      expect(HouseholdCode.normalize('kz74qm'), 'KZ74QM');
    });

    test('drops the spaces and dashes people add when reading aloud', () {
      expect(HouseholdCode.normalize('KZ 74 QM'), 'KZ74QM');
      expect(HouseholdCode.normalize('KZ-74-QM'), 'KZ74QM');
    });

    test('forgives the confusions the alphabet avoids', () {
      // Typing O for zero should get you in, not send you back to ask for the
      // code again.
      expect(
        HouseholdCode.normalize('K0740M'),
        HouseholdCode.normalize('KO74OM'),
      );
      expect(
        HouseholdCode.normalize('1A2B3C'),
        HouseholdCode.normalize('IA2B3C'),
      );
      expect(
        HouseholdCode.normalize('1A2B3C'),
        HouseholdCode.normalize('LA2B3C'),
      );
    });

    test('a generated code survives a round trip unchanged', () {
      for (var i = 0; i < 500; i++) {
        final code = HouseholdCode.generate();
        expect(HouseholdCode.normalize(code), code);
      }
    });
  });

  group('isWellFormed', () {
    test('accepts a real code, however it was typed', () {
      expect(HouseholdCode.isWellFormed('KZ74QM'), isTrue);
      expect(HouseholdCode.isWellFormed(' kz 74 qm '), isTrue);
    });

    test('rejects what cannot be one', () {
      expect(HouseholdCode.isWellFormed(''), isFalse);
      expect(HouseholdCode.isWellFormed('KZ74Q'), isFalse);
      expect(HouseholdCode.isWellFormed('KZ74QMX'), isFalse);
      expect(HouseholdCode.isWellFormed('KZ74Q!'), isFalse);
    });
  });
}
