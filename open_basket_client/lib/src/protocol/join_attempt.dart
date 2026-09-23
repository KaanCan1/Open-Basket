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

/// One failed attempt to join with a code (ADR-045). A six-character code is
/// the only thing between a stranger and a household, so wrong guesses are
/// counted per account and capped.
abstract class JoinAttempt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  JoinAttempt._({
    this.id,
    required this.userId,
    required this.attemptedAt,
  });

  factory JoinAttempt({
    int? id,
    required _isc.UuidValue userId,
    required DateTime attemptedAt,
  }) = _JoinAttemptImpl;

  factory JoinAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return JoinAttempt(
      id: jsonSerialization['id'] as int?,
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      attemptedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['attemptedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue userId;

  DateTime attemptedAt;

  /// Returns a shallow copy of this [JoinAttempt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  JoinAttempt copyWith({
    int? id,
    _isc.UuidValue? userId,
    DateTime? attemptedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JoinAttempt',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      'attemptedAt': attemptedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'JoinAttempt',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      'attemptedAt': attemptedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JoinAttemptImpl extends JoinAttempt {
  _JoinAttemptImpl({
    int? id,
    required _isc.UuidValue userId,
    required DateTime attemptedAt,
  }) : super._(
         id: id,
         userId: userId,
         attemptedAt: attemptedAt,
       );

  /// Returns a shallow copy of this [JoinAttempt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  JoinAttempt copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? userId,
    DateTime? attemptedAt,
  }) {
    return JoinAttempt(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      attemptedAt: attemptedAt ?? this.attemptedAt,
    );
  }
}
