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
import 'package:open_basket_server/src/generated/protocol.dart' as _ixxm76mw;
import 'package:serverpod/serverpod.dart' as _is;
import 'basket.dart' as _incyaby3;
import 'basket_event_type.dart' as _i1f6eto5;
import 'basket_item.dart' as _iqfe96ip;

/// Pushed over the live basket stream. Not a table.
///
/// The first event on every connection is a `snapshot` carrying the whole
/// basket, so a client that reconnects can resync without a second call.
abstract class BasketEvent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  BasketEvent._({
    required this.type,
    this.basket,
    this.items,
    this.item,
    required this.serverTime,
  });

  factory BasketEvent({
    required _i1f6eto5.BasketEventType type,
    _incyaby3.Basket? basket,
    List<_iqfe96ip.BasketItem>? items,
    _iqfe96ip.BasketItem? item,
    required DateTime serverTime,
  }) = _BasketEventImpl;

  factory BasketEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return BasketEvent(
      type: _i1f6eto5.BasketEventType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      basket: jsonSerialization['basket'] == null
          ? null
          : _ixxm76mw.Protocol().deserialize<_incyaby3.Basket>(
              jsonSerialization['basket'],
            ),
      items: jsonSerialization['items'] == null
          ? null
          : _ixxm76mw.Protocol().deserialize<List<_iqfe96ip.BasketItem>>(
              jsonSerialization['items'],
            ),
      item: jsonSerialization['item'] == null
          ? null
          : _ixxm76mw.Protocol().deserialize<_iqfe96ip.BasketItem>(
              jsonSerialization['item'],
            ),
      serverTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['serverTime'],
      ),
    );
  }

  _i1f6eto5.BasketEventType type;

  _incyaby3.Basket? basket;

  /// Set on `snapshot`.
  List<_iqfe96ip.BasketItem>? items;

  /// Set on the single-item events.
  _iqfe96ip.BasketItem? item;

  /// Sent on every event so the client can keep correcting for clock drift.
  DateTime serverTime;

  /// Returns a shallow copy of this [BasketEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BasketEvent copyWith({
    _i1f6eto5.BasketEventType? type,
    _incyaby3.Basket? basket,
    List<_iqfe96ip.BasketItem>? items,
    _iqfe96ip.BasketItem? item,
    DateTime? serverTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BasketEvent',
      'type': type.toJson(),
      if (basket != null) 'basket': basket?.toJson(),
      if (items != null) 'items': items?.toJson(valueToJson: (v) => v.toJson()),
      if (item != null) 'item': item?.toJson(),
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BasketEvent',
      'type': type.toJson(),
      if (basket != null) 'basket': basket?.toJsonForProtocol(),
      if (items != null)
        'items': items?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (item != null) 'item': item?.toJsonForProtocol(),
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BasketEventImpl extends BasketEvent {
  _BasketEventImpl({
    required _i1f6eto5.BasketEventType type,
    _incyaby3.Basket? basket,
    List<_iqfe96ip.BasketItem>? items,
    _iqfe96ip.BasketItem? item,
    required DateTime serverTime,
  }) : super._(
         type: type,
         basket: basket,
         items: items,
         item: item,
         serverTime: serverTime,
       );

  /// Returns a shallow copy of this [BasketEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BasketEvent copyWith({
    _i1f6eto5.BasketEventType? type,
    Object? basket = _Undefined,
    Object? items = _Undefined,
    Object? item = _Undefined,
    DateTime? serverTime,
  }) {
    return BasketEvent(
      type: type ?? this.type,
      basket: basket is _incyaby3.Basket? ? basket : this.basket?.copyWith(),
      items: items is List<_iqfe96ip.BasketItem>?
          ? items
          : this.items?.map((e0) => e0.copyWith()).toList(),
      item: item is _iqfe96ip.BasketItem? ? item : this.item?.copyWith(),
      serverTime: serverTime ?? this.serverTime,
    );
  }
}
