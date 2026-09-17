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

/// Who owes whom after a run. Immutable once written.
abstract class SettlementLine
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SettlementLine._({
    this.id,
    required this.basketId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amountMinor,
    required this.itemsMinor,
    required this.receiptGapMinor,
  });

  factory SettlementLine({
    int? id,
    required int basketId,
    required int fromMemberId,
    required int toMemberId,
    required int amountMinor,
    required int itemsMinor,
    required int receiptGapMinor,
  }) = _SettlementLineImpl;

  factory SettlementLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return SettlementLine(
      id: jsonSerialization['id'] as int?,
      basketId: jsonSerialization['basketId'] as int,
      fromMemberId: jsonSerialization['fromMemberId'] as int,
      toMemberId: jsonSerialization['toMemberId'] as int,
      amountMinor: jsonSerialization['amountMinor'] as int,
      itemsMinor: jsonSerialization['itemsMinor'] as int,
      receiptGapMinor: jsonSerialization['receiptGapMinor'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int basketId;

  int fromMemberId;

  int toMemberId;

  /// Total owed, in minor units: own picked items plus a share of the gap.
  int amountMinor;

  /// The two terms above, kept separately so the UI can show
  /// "₺84.50 items + ₺0.50 gap" without recomputing (ADR-007).
  int itemsMinor;

  int receiptGapMinor;

  /// Returns a shallow copy of this [SettlementLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SettlementLine copyWith({
    int? id,
    int? basketId,
    int? fromMemberId,
    int? toMemberId,
    int? amountMinor,
    int? itemsMinor,
    int? receiptGapMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SettlementLine',
      if (id != null) 'id': id,
      'basketId': basketId,
      'fromMemberId': fromMemberId,
      'toMemberId': toMemberId,
      'amountMinor': amountMinor,
      'itemsMinor': itemsMinor,
      'receiptGapMinor': receiptGapMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SettlementLine',
      if (id != null) 'id': id,
      'basketId': basketId,
      'fromMemberId': fromMemberId,
      'toMemberId': toMemberId,
      'amountMinor': amountMinor,
      'itemsMinor': itemsMinor,
      'receiptGapMinor': receiptGapMinor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SettlementLineImpl extends SettlementLine {
  _SettlementLineImpl({
    int? id,
    required int basketId,
    required int fromMemberId,
    required int toMemberId,
    required int amountMinor,
    required int itemsMinor,
    required int receiptGapMinor,
  }) : super._(
         id: id,
         basketId: basketId,
         fromMemberId: fromMemberId,
         toMemberId: toMemberId,
         amountMinor: amountMinor,
         itemsMinor: itemsMinor,
         receiptGapMinor: receiptGapMinor,
       );

  /// Returns a shallow copy of this [SettlementLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SettlementLine copyWith({
    Object? id = _Undefined,
    int? basketId,
    int? fromMemberId,
    int? toMemberId,
    int? amountMinor,
    int? itemsMinor,
    int? receiptGapMinor,
  }) {
    return SettlementLine(
      id: id is int? ? id : this.id,
      basketId: basketId ?? this.basketId,
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      amountMinor: amountMinor ?? this.amountMinor,
      itemsMinor: itemsMinor ?? this.itemsMinor,
      receiptGapMinor: receiptGapMinor ?? this.receiptGapMinor,
    );
  }
}
