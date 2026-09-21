import 'package:flutter_test/flutter_test.dart';
import 'package:open_basket_flutter/src/features/household/household_code_formatter.dart';

void main() {
  group('household code input', () {
    test('upper-cases whatever was typed', () {
      expect(HouseholdCodeFormatter.normalize('k2mrqf'), 'K2MRQF');
    });

    test('folds the letters the alphabet leaves out', () {
      // Someone reading a code aloud says "oh" for a zero and "one" for a
      // one. The alphabet drops I, L and O so those readings cannot be
      // ambiguous, and the server folds them the same way.
      expect(HouseholdCodeFormatter.normalize('O1L2I3'), '011213');
    });

    test('drops anything outside the alphabet', () {
      expect(HouseholdCodeFormatter.normalize('K2-MR QF'), 'K2MRQF');
      expect(HouseholdCodeFormatter.normalize('k2@mr!qf'), 'K2MRQF');
    });

    test('never grows past six characters', () {
      expect(HouseholdCodeFormatter.normalize('K2MRQFXXXX'), 'K2MRQF');
    });

    test('the alphabet is the one the server generates from', () {
      // If these ever drift, a code the server issued would be untypeable.
      expect(HouseholdCodeFormatter.alphabet.contains('I'), isFalse);
      expect(HouseholdCodeFormatter.alphabet.contains('L'), isFalse);
      expect(HouseholdCodeFormatter.alphabet.contains('O'), isFalse);
      expect(HouseholdCodeFormatter.alphabet.contains('0'), isTrue);
      expect(HouseholdCodeFormatter.alphabet.contains('1'), isTrue);
      expect(HouseholdCodeFormatter.alphabet, hasLength(33));
    });
  });
}
