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
import 'basket_status.dart' as _iumwz8so;

/// One shopping run. At most one per household may be open at a time.
abstract class Basket
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Basket._({
    this.id,
    required this.householdId,
    required this.shopperMemberId,
    this.storeId,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    required this.closesAt,
    this.frozenAt,
    bool? closedAutomatically,
    int? extendCount,
    this.receiptTotalMinor,
    String? currencyCode,
  }) : status = status ?? _iumwz8so.BasketStatus.open,
       openedAt = openedAt ?? DateTime.now(),
       closedAutomatically = closedAutomatically ?? false,
       extendCount = extendCount ?? 0,
       currencyCode = currencyCode ?? 'TRY';

  factory Basket({
    int? id,
    required int householdId,
    required int shopperMemberId,
    int? storeId,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    required DateTime closesAt,
    DateTime? frozenAt,
    bool? closedAutomatically,
    int? extendCount,
    int? receiptTotalMinor,
    String? currencyCode,
  }) = _BasketImpl;

  factory Basket.fromJson(Map<String, dynamic> jsonSerialization) {
    return Basket(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      shopperMemberId: jsonSerialization['shopperMemberId'] as int,
      storeId: jsonSerialization['storeId'] as int?,
      status: jsonSerialization['status'] == null
          ? null
          : _iumwz8so.BasketStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      openedAt: jsonSerialization['openedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['openedAt']),
      closesAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['closesAt'],
      ),
      frozenAt: jsonSerialization['frozenAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['frozenAt']),
      closedAutomatically: jsonSerialization['closedAutomatically'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['closedAutomatically'],
            ),
      extendCount: jsonSerialization['extendCount'] as int?,
      receiptTotalMinor: jsonSerialization['receiptTotalMinor'] as int?,
      currencyCode: jsonSerialization['currencyCode'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int householdId;

  /// The member doing the shopping. Only they may extend, freeze, mark items,
  /// enter prices, settle or cancel.
  int shopperMemberId;

  int? storeId;

  _iumwz8so.BasketStatus status;

  DateTime openedAt;

  /// The server owns this. The client only renders closesAt - serverNow.
  DateTime closesAt;

  DateTime? frozenAt;

  /// True when the future call closed it rather than the shopper.
  bool closedAutomatically;

  /// One +5 min extension per basket (ADR-009), so this is 0 or 1.
  int extendCount;

  /// What the till actually charged, in minor units. Null until entered.
  int? receiptTotalMinor;

  /// The household's currency at the moment this basket closed. A settled
  /// basket keeps it, so changing the household setting never rewrites history.
  String currencyCode;

  /// Returns a shallow copy of this [Basket]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Basket copyWith({
    int? id,
    int? householdId,
    int? shopperMemberId,
    int? storeId,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    DateTime? closesAt,
    DateTime? frozenAt,
    bool? closedAutomatically,
    int? extendCount,
    int? receiptTotalMinor,
    String? currencyCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Basket',
      if (id != null) 'id': id,
      'householdId': householdId,
      'shopperMemberId': shopperMemberId,
      if (storeId != null) 'storeId': storeId,
      'status': status.toJson(),
      'openedAt': openedAt.toJson(),
      'closesAt': closesAt.toJson(),
      if (frozenAt != null) 'frozenAt': frozenAt?.toJson(),
      'closedAutomatically': closedAutomatically,
      'extendCount': extendCount,
      if (receiptTotalMinor != null) 'receiptTotalMinor': receiptTotalMinor,
      'currencyCode': currencyCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Basket',
      if (id != null) 'id': id,
      'householdId': householdId,
      'shopperMemberId': shopperMemberId,
      if (storeId != null) 'storeId': storeId,
      'status': status.toJson(),
      'openedAt': openedAt.toJson(),
      'closesAt': closesAt.toJson(),
      if (frozenAt != null) 'frozenAt': frozenAt?.toJson(),
      'closedAutomatically': closedAutomatically,
      'extendCount': extendCount,
      if (receiptTotalMinor != null) 'receiptTotalMinor': receiptTotalMinor,
      'currencyCode': currencyCode,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BasketImpl extends Basket {
  _BasketImpl({
    int? id,
    required int householdId,
    required int shopperMemberId,
    int? storeId,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    required DateTime closesAt,
    DateTime? frozenAt,
    bool? closedAutomatically,
    int? extendCount,
    int? receiptTotalMinor,
    String? currencyCode,
  }) : super._(
         id: id,
         householdId: householdId,
         shopperMemberId: shopperMemberId,
         storeId: storeId,
         status: status,
         openedAt: openedAt,
         closesAt: closesAt,
         frozenAt: frozenAt,
         closedAutomatically: closedAutomatically,
         extendCount: extendCount,
         receiptTotalMinor: receiptTotalMinor,
         currencyCode: currencyCode,
       );

  /// Returns a shallow copy of this [Basket]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Basket copyWith({
    Object? id = _Undefined,
    int? householdId,
    int? shopperMemberId,
    Object? storeId = _Undefined,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    DateTime? closesAt,
    Object? frozenAt = _Undefined,
    bool? closedAutomatically,
    int? extendCount,
    Object? receiptTotalMinor = _Undefined,
    String? currencyCode,
  }) {
    return Basket(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      shopperMemberId: shopperMemberId ?? this.shopperMemberId,
      storeId: storeId is int? ? storeId : this.storeId,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      closesAt: closesAt ?? this.closesAt,
      frozenAt: frozenAt is DateTime? ? frozenAt : this.frozenAt,
      closedAutomatically: closedAutomatically ?? this.closedAutomatically,
      extendCount: extendCount ?? this.extendCount,
      receiptTotalMinor: receiptTotalMinor is int?
          ? receiptTotalMinor
          : this.receiptTotalMinor,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
