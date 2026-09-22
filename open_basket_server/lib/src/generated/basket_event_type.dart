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
import 'package:serverpod/serverpod.dart' as _is;

enum BasketEventType implements _is.SerializableModel {
  snapshot,
  itemAdded,
  itemUpdated,
  itemRemoved,
  timerExtended,
  basketFrozen,
  basketSettled,
  basketCancelled,

  /// Something about the basket itself changed that is not a lifecycle step:
  /// today, the shopper entering the receipt total. Carries the basket.
  basketUpdated;

  static BasketEventType fromJson(String name) {
    switch (name) {
      case 'snapshot':
        return BasketEventType.snapshot;
      case 'itemAdded':
        return BasketEventType.itemAdded;
      case 'itemUpdated':
        return BasketEventType.itemUpdated;
      case 'itemRemoved':
        return BasketEventType.itemRemoved;
      case 'timerExtended':
        return BasketEventType.timerExtended;
      case 'basketFrozen':
        return BasketEventType.basketFrozen;
      case 'basketSettled':
        return BasketEventType.basketSettled;
      case 'basketCancelled':
        return BasketEventType.basketCancelled;
      case 'basketUpdated':
        return BasketEventType.basketUpdated;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "BasketEventType"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
