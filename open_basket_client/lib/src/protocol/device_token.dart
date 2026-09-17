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

/// An FCM registration token for one installation.
abstract class DeviceToken
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DeviceToken._({
    this.id,
    required this.userId,
    required this.token,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory DeviceToken({
    int? id,
    required _isc.UuidValue userId,
    required String token,
    DateTime? updatedAt,
  }) = _DeviceTokenImpl;

  factory DeviceToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeviceToken(
      id: jsonSerialization['id'] as int?,
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      token: jsonSerialization['token'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue userId;

  String token;

  DateTime updatedAt;

  /// Returns a shallow copy of this [DeviceToken]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DeviceToken copyWith({
    int? id,
    _isc.UuidValue? userId,
    String? token,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeviceToken',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      'token': token,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DeviceToken',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      'token': token,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeviceTokenImpl extends DeviceToken {
  _DeviceTokenImpl({
    int? id,
    required _isc.UuidValue userId,
    required String token,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         token: token,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [DeviceToken]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DeviceToken copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? userId,
    String? token,
    DateTime? updatedAt,
  }) {
    return DeviceToken(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
