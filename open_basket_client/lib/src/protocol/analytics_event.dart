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

/// Every key event lands here. The Day 26 report is built from this table, so
/// a metric added later is data already lost.
abstract class AnalyticsEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AnalyticsEvent._({
    this.id,
    required this.type,
    this.householdId,
    this.basketId,
    this.memberId,
    this.payload,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AnalyticsEvent({
    int? id,
    required String type,
    int? householdId,
    int? basketId,
    int? memberId,
    String? payload,
    DateTime? createdAt,
  }) = _AnalyticsEventImpl;

  factory AnalyticsEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnalyticsEvent(
      id: jsonSerialization['id'] as int?,
      type: jsonSerialization['type'] as String,
      householdId: jsonSerialization['householdId'] as int?,
      basketId: jsonSerialization['basketId'] as int?,
      memberId: jsonSerialization['memberId'] as int?,
      payload: jsonSerialization['payload'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String type;

  int? householdId;

  int? basketId;

  int? memberId;

  /// JSON blob, free shape per event type.
  String? payload;

  DateTime createdAt;

  /// Returns a shallow copy of this [AnalyticsEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AnalyticsEvent copyWith({
    int? id,
    String? type,
    int? householdId,
    int? basketId,
    int? memberId,
    String? payload,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AnalyticsEvent',
      if (id != null) 'id': id,
      'type': type,
      if (householdId != null) 'householdId': householdId,
      if (basketId != null) 'basketId': basketId,
      if (memberId != null) 'memberId': memberId,
      if (payload != null) 'payload': payload,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AnalyticsEvent',
      if (id != null) 'id': id,
      'type': type,
      if (householdId != null) 'householdId': householdId,
      if (basketId != null) 'basketId': basketId,
      if (memberId != null) 'memberId': memberId,
      if (payload != null) 'payload': payload,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AnalyticsEventImpl extends AnalyticsEvent {
  _AnalyticsEventImpl({
    int? id,
    required String type,
    int? householdId,
    int? basketId,
    int? memberId,
    String? payload,
    DateTime? createdAt,
  }) : super._(
         id: id,
         type: type,
         householdId: householdId,
         basketId: basketId,
         memberId: memberId,
         payload: payload,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AnalyticsEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AnalyticsEvent copyWith({
    Object? id = _Undefined,
    String? type,
    Object? householdId = _Undefined,
    Object? basketId = _Undefined,
    Object? memberId = _Undefined,
    Object? payload = _Undefined,
    DateTime? createdAt,
  }) {
    return AnalyticsEvent(
      id: id is int? ? id : this.id,
      type: type ?? this.type,
      householdId: householdId is int? ? householdId : this.householdId,
      basketId: basketId is int? ? basketId : this.basketId,
      memberId: memberId is int? ? memberId : this.memberId,
      payload: payload is String? ? payload : this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
