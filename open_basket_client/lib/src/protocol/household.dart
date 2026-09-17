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

/// A group of people who shop for each other. A user belongs to one at a time.
abstract class Household
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Household._({
    this.id,
    required this.name,
    String? currencyCode,
    required this.code,
    DateTime? createdAt,
  }) : currencyCode = currencyCode ?? 'TRY',
       createdAt = createdAt ?? DateTime.now();

  factory Household({
    int? id,
    required String name,
    String? currencyCode,
    required String code,
    DateTime? createdAt,
  }) = _HouseholdImpl;

  factory Household.fromJson(Map<String, dynamic> jsonSerialization) {
    return Household(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      currencyCode: jsonSerialization['currencyCode'] as String?,
      code: jsonSerialization['code'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Display name, e.g. "Kaya household".
  String name;

  /// ISO 4217 code. Every price, settlement and shared summary uses it (ADR-008).
  String currencyCode;

  /// Permanent six-character join code. Owner-rotatable; rotating invalidates
  /// the previous code immediately (ADR-006). There is no expiry.
  String code;

  DateTime createdAt;

  /// Returns a shallow copy of this [Household]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Household copyWith({
    int? id,
    String? name,
    String? currencyCode,
    String? code,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Household',
      if (id != null) 'id': id,
      'name': name,
      'currencyCode': currencyCode,
      'code': code,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Household',
      if (id != null) 'id': id,
      'name': name,
      'currencyCode': currencyCode,
      'code': code,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HouseholdImpl extends Household {
  _HouseholdImpl({
    int? id,
    required String name,
    String? currencyCode,
    required String code,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         currencyCode: currencyCode,
         code: code,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Household]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Household copyWith({
    Object? id = _Undefined,
    String? name,
    String? currencyCode,
    String? code,
    DateTime? createdAt,
  }) {
    return Household(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
