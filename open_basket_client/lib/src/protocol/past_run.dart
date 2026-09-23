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
import 'package:open_basket_client/src/protocol/protocol.dart' as _ix10ipnp;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'basket.dart' as _incyaby3;

/// One finished run as the history list shows it: the basket plus the few
/// numbers its row needs, so the list is one call rather than one per row.
/// Not a table.
abstract class PastRun
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PastRun._({
    required this.basket,
    required this.totalMinor,
    required this.itemCount,
    required this.unavailableCount,
    required this.itemsByMember,
  });

  factory PastRun({
    required _incyaby3.Basket basket,
    required int totalMinor,
    required int itemCount,
    required int unavailableCount,
    required Map<int, int> itemsByMember,
  }) = _PastRunImpl;

  factory PastRun.fromJson(Map<String, dynamic> jsonSerialization) {
    return PastRun(
      basket: _ix10ipnp.Protocol().deserialize<_incyaby3.Basket>(
        jsonSerialization['basket'],
      ),
      totalMinor: jsonSerialization['totalMinor'] as int,
      itemCount: jsonSerialization['itemCount'] as int,
      unavailableCount: jsonSerialization['unavailableCount'] as int,
      itemsByMember: _ix10ipnp.Protocol().deserialize<Map<int, int>>(
        jsonSerialization['itemsByMember'],
      ),
    );
  }

  _incyaby3.Basket basket;

  /// What the run cost the house, in minor units: the receipt total if the
  /// shopper entered one, else the priced items. Zero for a cancelled run.
  int totalMinor;

  int itemCount;

  int unavailableCount;

  /// Member id → how many items they asked for. The row's person chips.
  Map<int, int> itemsByMember;

  /// Returns a shallow copy of this [PastRun]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PastRun copyWith({
    _incyaby3.Basket? basket,
    int? totalMinor,
    int? itemCount,
    int? unavailableCount,
    Map<int, int>? itemsByMember,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PastRun',
      'basket': basket.toJson(),
      'totalMinor': totalMinor,
      'itemCount': itemCount,
      'unavailableCount': unavailableCount,
      'itemsByMember': itemsByMember.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PastRun',
      'basket': basket.toJsonForProtocol(),
      'totalMinor': totalMinor,
      'itemCount': itemCount,
      'unavailableCount': unavailableCount,
      'itemsByMember': itemsByMember.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PastRunImpl extends PastRun {
  _PastRunImpl({
    required _incyaby3.Basket basket,
    required int totalMinor,
    required int itemCount,
    required int unavailableCount,
    required Map<int, int> itemsByMember,
  }) : super._(
         basket: basket,
         totalMinor: totalMinor,
         itemCount: itemCount,
         unavailableCount: unavailableCount,
         itemsByMember: itemsByMember,
       );

  /// Returns a shallow copy of this [PastRun]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PastRun copyWith({
    _incyaby3.Basket? basket,
    int? totalMinor,
    int? itemCount,
    int? unavailableCount,
    Map<int, int>? itemsByMember,
  }) {
    return PastRun(
      basket: basket ?? this.basket.copyWith(),
      totalMinor: totalMinor ?? this.totalMinor,
      itemCount: itemCount ?? this.itemCount,
      unavailableCount: unavailableCount ?? this.unavailableCount,
      itemsByMember:
          itemsByMember ??
          this.itemsByMember.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
    );
  }
}
