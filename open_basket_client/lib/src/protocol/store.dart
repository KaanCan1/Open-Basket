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

/// A shop the household uses. Only its fixed location, never anyone's live position.
abstract class Store
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Store._({
    this.id,
    required this.householdId,
    required this.name,
    this.lat,
    this.lng,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Store({
    int? id,
    required int householdId,
    required String name,
    double? lat,
    double? lng,
    DateTime? createdAt,
  }) = _StoreImpl;

  factory Store.fromJson(Map<String, dynamic> jsonSerialization) {
    return Store(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      name: jsonSerialization['name'] as String,
      lat: (jsonSerialization['lat'] as num?)?.toDouble(),
      lng: (jsonSerialization['lng'] as num?)?.toDouble(),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int householdId;

  String name;

  /// Pinned once when the store is added, so the client can suggest a duration.
  /// Null when the member skipped the location step.
  double? lat;

  double? lng;

  DateTime createdAt;

  /// Returns a shallow copy of this [Store]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Store copyWith({
    int? id,
    int? householdId,
    String? name,
    double? lat,
    double? lng,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Store',
      if (id != null) 'id': id,
      'householdId': householdId,
      'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Store',
      if (id != null) 'id': id,
      'householdId': householdId,
      'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoreImpl extends Store {
  _StoreImpl({
    int? id,
    required int householdId,
    required String name,
    double? lat,
    double? lng,
    DateTime? createdAt,
  }) : super._(
         id: id,
         householdId: householdId,
         name: name,
         lat: lat,
         lng: lng,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Store]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Store copyWith({
    Object? id = _Undefined,
    int? householdId,
    String? name,
    Object? lat = _Undefined,
    Object? lng = _Undefined,
    DateTime? createdAt,
  }) {
    return Store(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      lat: lat is double? ? lat : this.lat,
      lng: lng is double? ? lng : this.lng,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
