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

/// A household code that was rotated away (ADR-045). Kept so a join with it
/// can say "that code has been replaced" instead of "no such code", and so it
/// is never handed to another household: a code in an old group chat must
/// not start opening a stranger's house.
abstract class RetiredHouseholdCode
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RetiredHouseholdCode._({
    this.id,
    required this.householdId,
    required this.code,
    required this.retiredAt,
  });

  factory RetiredHouseholdCode({
    int? id,
    required int householdId,
    required String code,
    required DateTime retiredAt,
  }) = _RetiredHouseholdCodeImpl;

  factory RetiredHouseholdCode.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RetiredHouseholdCode(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      code: jsonSerialization['code'] as String,
      retiredAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['retiredAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int householdId;

  String code;

  DateTime retiredAt;

  /// Returns a shallow copy of this [RetiredHouseholdCode]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RetiredHouseholdCode copyWith({
    int? id,
    int? householdId,
    String? code,
    DateTime? retiredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RetiredHouseholdCode',
      if (id != null) 'id': id,
      'householdId': householdId,
      'code': code,
      'retiredAt': retiredAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RetiredHouseholdCode',
      if (id != null) 'id': id,
      'householdId': householdId,
      'code': code,
      'retiredAt': retiredAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RetiredHouseholdCodeImpl extends RetiredHouseholdCode {
  _RetiredHouseholdCodeImpl({
    int? id,
    required int householdId,
    required String code,
    required DateTime retiredAt,
  }) : super._(
         id: id,
         householdId: householdId,
         code: code,
         retiredAt: retiredAt,
       );

  /// Returns a shallow copy of this [RetiredHouseholdCode]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RetiredHouseholdCode copyWith({
    Object? id = _Undefined,
    int? householdId,
    String? code,
    DateTime? retiredAt,
  }) {
    return RetiredHouseholdCode(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      code: code ?? this.code,
      retiredAt: retiredAt ?? this.retiredAt,
    );
  }
}
