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
import 'item_status.dart' as _ibbyonnn;
import 'item_unit.dart' as _iplumtmx;

/// Something a member asked for on a run.
abstract class BasketItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  BasketItem._({
    this.id,
    required this.basketId,
    required this.requesterMemberId,
    required this.name,
    int? quantity,
    _iplumtmx.ItemUnit? unit,
    this.note,
    _ibbyonnn.ItemStatus? status,
    this.priceMinor,
    DateTime? addedAt,
  }) : quantity = quantity ?? 1,
       unit = unit ?? _iplumtmx.ItemUnit.piece,
       status = status ?? _ibbyonnn.ItemStatus.requested,
       addedAt = addedAt ?? DateTime.now();

  factory BasketItem({
    int? id,
    required int basketId,
    required int requesterMemberId,
    required String name,
    int? quantity,
    _iplumtmx.ItemUnit? unit,
    String? note,
    _ibbyonnn.ItemStatus? status,
    int? priceMinor,
    DateTime? addedAt,
  }) = _BasketItemImpl;

  factory BasketItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return BasketItem(
      id: jsonSerialization['id'] as int?,
      basketId: jsonSerialization['basketId'] as int,
      requesterMemberId: jsonSerialization['requesterMemberId'] as int,
      name: jsonSerialization['name'] as String,
      quantity: jsonSerialization['quantity'] as int?,
      unit: jsonSerialization['unit'] == null
          ? null
          : _iplumtmx.ItemUnit.fromJson((jsonSerialization['unit'] as String)),
      note: jsonSerialization['note'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _ibbyonnn.ItemStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      priceMinor: jsonSerialization['priceMinor'] as int?,
      addedAt: jsonSerialization['addedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int basketId;

  /// Who asked for it. Drives the avatar on the row and who owes for it.
  int requesterMemberId;

  String name;

  int quantity;

  /// What the quantity counts. Pieces unless someone says otherwise.
  _iplumtmx.ItemUnit unit;

  /// Free text: brand, size, "only if fresh".
  String? note;

  /// The shopper may set this while the basket is still open (ADR-005).
  _ibbyonnn.ItemStatus status;

  /// Minor units. Only set once the basket is frozen.
  int? priceMinor;

  DateTime addedAt;

  /// Returns a shallow copy of this [BasketItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  BasketItem copyWith({
    int? id,
    int? basketId,
    int? requesterMemberId,
    String? name,
    int? quantity,
    _iplumtmx.ItemUnit? unit,
    String? note,
    _ibbyonnn.ItemStatus? status,
    int? priceMinor,
    DateTime? addedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BasketItem',
      if (id != null) 'id': id,
      'basketId': basketId,
      'requesterMemberId': requesterMemberId,
      'name': name,
      'quantity': quantity,
      'unit': unit.toJson(),
      if (note != null) 'note': note,
      'status': status.toJson(),
      if (priceMinor != null) 'priceMinor': priceMinor,
      'addedAt': addedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BasketItem',
      if (id != null) 'id': id,
      'basketId': basketId,
      'requesterMemberId': requesterMemberId,
      'name': name,
      'quantity': quantity,
      'unit': unit.toJson(),
      if (note != null) 'note': note,
      'status': status.toJson(),
      if (priceMinor != null) 'priceMinor': priceMinor,
      'addedAt': addedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BasketItemImpl extends BasketItem {
  _BasketItemImpl({
    int? id,
    required int basketId,
    required int requesterMemberId,
    required String name,
    int? quantity,
    _iplumtmx.ItemUnit? unit,
    String? note,
    _ibbyonnn.ItemStatus? status,
    int? priceMinor,
    DateTime? addedAt,
  }) : super._(
         id: id,
         basketId: basketId,
         requesterMemberId: requesterMemberId,
         name: name,
         quantity: quantity,
         unit: unit,
         note: note,
         status: status,
         priceMinor: priceMinor,
         addedAt: addedAt,
       );

  /// Returns a shallow copy of this [BasketItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  BasketItem copyWith({
    Object? id = _Undefined,
    int? basketId,
    int? requesterMemberId,
    String? name,
    int? quantity,
    _iplumtmx.ItemUnit? unit,
    Object? note = _Undefined,
    _ibbyonnn.ItemStatus? status,
    Object? priceMinor = _Undefined,
    DateTime? addedAt,
  }) {
    return BasketItem(
      id: id is int? ? id : this.id,
      basketId: basketId ?? this.basketId,
      requesterMemberId: requesterMemberId ?? this.requesterMemberId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      note: note is String? ? note : this.note,
      status: status ?? this.status,
      priceMinor: priceMinor is int? ? priceMinor : this.priceMinor,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
