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
import 'member_role.dart' as _insyygng;

/// A user's membership of a household.
abstract class HouseholdMember
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  HouseholdMember._({
    this.id,
    required this.householdId,
    required this.userId,
    required this.displayName,
    _insyygng.MemberRole? role,
    bool? notifyBasketOpened,
    bool? notifyClosingSoon,
    bool? notifySettlementReady,
    DateTime? joinedAt,
    this.leftAt,
  }) : role = role ?? _insyygng.MemberRole.member,
       notifyBasketOpened = notifyBasketOpened ?? true,
       notifyClosingSoon = notifyClosingSoon ?? true,
       notifySettlementReady = notifySettlementReady ?? true,
       joinedAt = joinedAt ?? DateTime.now();

  factory HouseholdMember({
    int? id,
    required int householdId,
    required _isc.UuidValue userId,
    required String displayName,
    _insyygng.MemberRole? role,
    bool? notifyBasketOpened,
    bool? notifyClosingSoon,
    bool? notifySettlementReady,
    DateTime? joinedAt,
    DateTime? leftAt,
  }) = _HouseholdMemberImpl;

  factory HouseholdMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return HouseholdMember(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      displayName: jsonSerialization['displayName'] as String,
      role: jsonSerialization['role'] == null
          ? null
          : _insyygng.MemberRole.fromJson(
              (jsonSerialization['role'] as String),
            ),
      notifyBasketOpened: jsonSerialization['notifyBasketOpened'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['notifyBasketOpened'],
            ),
      notifyClosingSoon: jsonSerialization['notifyClosingSoon'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['notifyClosingSoon'],
            ),
      notifySettlementReady: jsonSerialization['notifySettlementReady'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['notifySettlementReady'],
            ),
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      leftAt: jsonSerialization['leftAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['leftAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int householdId;

  /// The Serverpod auth user. Auth ids are UUIDs, not ints.
  _isc.UuidValue userId;

  /// Shown on item rows and person chips.
  String displayName;

  _insyygng.MemberRole role;

  /// Notification preferences, checked on the server before sending (ADR-010).
  bool notifyBasketOpened;

  bool notifyClosingSoon;

  bool notifySettlementReady;

  DateTime joinedAt;

  /// Set when the member leaves; the row stays. Deleting it cascaded into
  /// their items, their settlement lines and any basket they had shopped —
  /// the history rule 6 says is immutable and the report is built from
  /// (ADR-036). Null for everyone still in.
  DateTime? leftAt;

  /// Returns a shallow copy of this [HouseholdMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  HouseholdMember copyWith({
    int? id,
    int? householdId,
    _isc.UuidValue? userId,
    String? displayName,
    _insyygng.MemberRole? role,
    bool? notifyBasketOpened,
    bool? notifyClosingSoon,
    bool? notifySettlementReady,
    DateTime? joinedAt,
    DateTime? leftAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HouseholdMember',
      if (id != null) 'id': id,
      'householdId': householdId,
      'userId': userId.toJson(),
      'displayName': displayName,
      'role': role.toJson(),
      'notifyBasketOpened': notifyBasketOpened,
      'notifyClosingSoon': notifyClosingSoon,
      'notifySettlementReady': notifySettlementReady,
      'joinedAt': joinedAt.toJson(),
      if (leftAt != null) 'leftAt': leftAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HouseholdMember',
      if (id != null) 'id': id,
      'householdId': householdId,
      'userId': userId.toJson(),
      'displayName': displayName,
      'role': role.toJson(),
      'notifyBasketOpened': notifyBasketOpened,
      'notifyClosingSoon': notifyClosingSoon,
      'notifySettlementReady': notifySettlementReady,
      'joinedAt': joinedAt.toJson(),
      if (leftAt != null) 'leftAt': leftAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HouseholdMemberImpl extends HouseholdMember {
  _HouseholdMemberImpl({
    int? id,
    required int householdId,
    required _isc.UuidValue userId,
    required String displayName,
    _insyygng.MemberRole? role,
    bool? notifyBasketOpened,
    bool? notifyClosingSoon,
    bool? notifySettlementReady,
    DateTime? joinedAt,
    DateTime? leftAt,
  }) : super._(
         id: id,
         householdId: householdId,
         userId: userId,
         displayName: displayName,
         role: role,
         notifyBasketOpened: notifyBasketOpened,
         notifyClosingSoon: notifyClosingSoon,
         notifySettlementReady: notifySettlementReady,
         joinedAt: joinedAt,
         leftAt: leftAt,
       );

  /// Returns a shallow copy of this [HouseholdMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  HouseholdMember copyWith({
    Object? id = _Undefined,
    int? householdId,
    _isc.UuidValue? userId,
    String? displayName,
    _insyygng.MemberRole? role,
    bool? notifyBasketOpened,
    bool? notifyClosingSoon,
    bool? notifySettlementReady,
    DateTime? joinedAt,
    Object? leftAt = _Undefined,
  }) {
    return HouseholdMember(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      notifyBasketOpened: notifyBasketOpened ?? this.notifyBasketOpened,
      notifyClosingSoon: notifyClosingSoon ?? this.notifyClosingSoon,
      notifySettlementReady:
          notifySettlementReady ?? this.notifySettlementReady,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt is DateTime? ? leftAt : this.leftAt,
    );
  }
}
