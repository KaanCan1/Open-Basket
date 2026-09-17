/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

enum BasketError implements _isc.SerializableModel {
  /// The caller is not a member of this household.
  notAMember,

  /// The action is shopper-only: extend, freeze, mark, price, settle, cancel.
  notTheShopper,

  /// Owner-only: rotating the code, renaming, changing currency.
  notTheOwner,

  /// Rule 4: a household may have one open basket at a time.
  householdAlreadyHasOpenBasket,

  /// A user belongs to one household at a time.
  alreadyInAHousehold,

  /// The six-character household code is wrong, or was rotated away.
  unknownHouseholdCode,
  basketNotOpen,
  basketNotFrozen,
  basketAlreadySettled,

  /// One +5 min extension per basket (ADR-009).
  extensionAlreadyUsed,
  invalidSignInCode,
  signInCodeExpired,
  tooManySignInAttempts;

  static BasketError fromJson(String name) {
    switch (name) {
      case 'notAMember':
        return BasketError.notAMember;
      case 'notTheShopper':
        return BasketError.notTheShopper;
      case 'notTheOwner':
        return BasketError.notTheOwner;
      case 'householdAlreadyHasOpenBasket':
        return BasketError.householdAlreadyHasOpenBasket;
      case 'alreadyInAHousehold':
        return BasketError.alreadyInAHousehold;
      case 'unknownHouseholdCode':
        return BasketError.unknownHouseholdCode;
      case 'basketNotOpen':
        return BasketError.basketNotOpen;
      case 'basketNotFrozen':
        return BasketError.basketNotFrozen;
      case 'basketAlreadySettled':
        return BasketError.basketAlreadySettled;
      case 'extensionAlreadyUsed':
        return BasketError.extensionAlreadyUsed;
      case 'invalidSignInCode':
        return BasketError.invalidSignInCode;
      case 'signInCodeExpired':
        return BasketError.signInCodeExpired;
      case 'tooManySignInAttempts':
        return BasketError.tooManySignInAttempts;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "BasketError"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
