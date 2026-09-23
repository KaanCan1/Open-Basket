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
import 'package:serverpod/serverpod.dart' as _is;
import 'member_role.dart' as _insyygng;

/// A user's membership of a household.
abstract class HouseholdMember
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
    required _is.UuidValue userId,
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
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      displayName: jsonSerialization['displayName'] as String,
      role: jsonSerialization['role'] == null
          ? null
          : _insyygng.MemberRole.fromJson(
              (jsonSerialization['role'] as String),
            ),
      notifyBasketOpened: jsonSerialization['notifyBasketOpened'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['notifyBasketOpened'],
            ),
      notifyClosingSoon: jsonSerialization['notifyClosingSoon'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['notifyClosingSoon'],
            ),
      notifySettlementReady: jsonSerialization['notifySettlementReady'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['notifySettlementReady'],
            ),
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      leftAt: jsonSerialization['leftAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leftAt']),
    );
  }

  static final t = HouseholdMemberTable();

  static const db = HouseholdMemberRepository._();

  @override
  int? id;

  int householdId;

  /// The Serverpod auth user. Auth ids are UUIDs, not ints.
  _is.UuidValue userId;

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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [HouseholdMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  HouseholdMember copyWith({
    int? id,
    int? householdId,
    _is.UuidValue? userId,
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

  static HouseholdMemberInclude include() {
    return HouseholdMemberInclude._();
  }

  static HouseholdMemberIncludeList includeList({
    _is.WhereExpressionBuilder<HouseholdMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<HouseholdMemberTable>? orderBy,
    _is.OrderByListBuilder<HouseholdMemberTable>? orderByList,
    HouseholdMemberInclude? include,
  }) {
    return HouseholdMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HouseholdMember.t),
      orderByList: orderByList?.call(HouseholdMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HouseholdMemberImpl extends HouseholdMember {
  _HouseholdMemberImpl({
    int? id,
    required int householdId,
    required _is.UuidValue userId,
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
  @_is.useResult
  @override
  HouseholdMember copyWith({
    Object? id = _Undefined,
    int? householdId,
    _is.UuidValue? userId,
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

class HouseholdMemberUpdateTable extends _is.UpdateTable<HouseholdMemberTable> {
  HouseholdMemberUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<_insyygng.MemberRole, _insyygng.MemberRole> role(
    _insyygng.MemberRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<bool, bool> notifyBasketOpened(bool value) => _is.ColumnValue(
    table.notifyBasketOpened,
    value,
  );

  _is.ColumnValue<bool, bool> notifyClosingSoon(bool value) => _is.ColumnValue(
    table.notifyClosingSoon,
    value,
  );

  _is.ColumnValue<bool, bool> notifySettlementReady(bool value) =>
      _is.ColumnValue(
        table.notifySettlementReady,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _is.ColumnValue(
        table.joinedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> leftAt(DateTime? value) =>
      _is.ColumnValue(
        table.leftAt,
        value,
      );
}

class HouseholdMemberTable extends _is.Table<int?> {
  HouseholdMemberTable({super.tableRelation})
    : super(tableName: 'household_member') {
    updateTable = HouseholdMemberUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    notifyBasketOpened = _is.ColumnBool(
      'notifyBasketOpened',
      this,
      hasDefault: true,
    );
    notifyClosingSoon = _is.ColumnBool(
      'notifyClosingSoon',
      this,
      hasDefault: true,
    );
    notifySettlementReady = _is.ColumnBool(
      'notifySettlementReady',
      this,
      hasDefault: true,
    );
    joinedAt = _is.ColumnDateTime(
      'joinedAt',
      this,
      hasDefault: true,
    );
    leftAt = _is.ColumnDateTime(
      'leftAt',
      this,
    );
  }

  late final HouseholdMemberUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  /// The Serverpod auth user. Auth ids are UUIDs, not ints.
  late final _is.ColumnUuid userId;

  /// Shown on item rows and person chips.
  late final _is.ColumnString displayName;

  late final _is.ColumnEnum<_insyygng.MemberRole> role;

  /// Notification preferences, checked on the server before sending (ADR-010).
  late final _is.ColumnBool notifyBasketOpened;

  late final _is.ColumnBool notifyClosingSoon;

  late final _is.ColumnBool notifySettlementReady;

  late final _is.ColumnDateTime joinedAt;

  /// Set when the member leaves; the row stays. Deleting it cascaded into
  /// their items, their settlement lines and any basket they had shopped —
  /// the history rule 6 says is immutable and the report is built from
  /// (ADR-036). Null for everyone still in.
  late final _is.ColumnDateTime leftAt;

  @override
  List<_is.Column> get columns => [
    id,
    householdId,
    userId,
    displayName,
    role,
    notifyBasketOpened,
    notifyClosingSoon,
    notifySettlementReady,
    joinedAt,
    leftAt,
  ];
}

class HouseholdMemberInclude extends _is.IncludeObject {
  HouseholdMemberInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => HouseholdMember.t;
}

class HouseholdMemberIncludeList extends _is.IncludeList {
  HouseholdMemberIncludeList._({
    _is.WhereExpressionBuilder<HouseholdMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(HouseholdMember.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => HouseholdMember.t;
}

class HouseholdMemberRepository {
  const HouseholdMemberRepository._();

  /// Returns a list of [HouseholdMember]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<HouseholdMember>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<HouseholdMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<HouseholdMemberTable>? orderBy,
    _is.OrderByListBuilder<HouseholdMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<HouseholdMember>(
      where: where?.call(HouseholdMember.t),
      orderBy: orderBy?.call(HouseholdMember.t),
      orderByList: orderByList?.call(HouseholdMember.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [HouseholdMember] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<HouseholdMember?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<HouseholdMemberTable>? where,
    int? offset,
    _is.OrderByBuilder<HouseholdMemberTable>? orderBy,
    _is.OrderByListBuilder<HouseholdMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<HouseholdMember>(
      where: where?.call(HouseholdMember.t),
      orderBy: orderBy?.call(HouseholdMember.t),
      orderByList: orderByList?.call(HouseholdMember.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [HouseholdMember] by its [id] or null if no such row exists.
  Future<HouseholdMember?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<HouseholdMember>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [HouseholdMember]s in the list and returns the inserted rows.
  ///
  /// The returned [HouseholdMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<HouseholdMember>> insert(
    _is.DatabaseSession session,
    List<HouseholdMember> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<HouseholdMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [HouseholdMember] and returns the inserted row.
  ///
  /// The returned [HouseholdMember] will have its `id` field set.
  Future<HouseholdMember> insertRow(
    _is.DatabaseSession session,
    HouseholdMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<HouseholdMember>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [HouseholdMember]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [HouseholdMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<HouseholdMember>> upsert(
    _is.DatabaseSession session,
    List<HouseholdMember> rows, {
    required _is.ColumnSelections<HouseholdMemberTable> conflictColumns,
    _is.ColumnSelections<HouseholdMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<HouseholdMemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<HouseholdMember>(
      rows,
      conflictColumns: conflictColumns(HouseholdMember.t),
      updateColumns: updateColumns?.call(HouseholdMember.t),
      updateWhere: updateWhere?.call(HouseholdMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [HouseholdMember] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [HouseholdMember] will have its `id` field set.
  Future<HouseholdMember?> upsertRow(
    _is.DatabaseSession session,
    HouseholdMember row, {
    required _is.ColumnSelections<HouseholdMemberTable> conflictColumns,
    _is.ColumnSelections<HouseholdMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<HouseholdMemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<HouseholdMember>(
      row,
      conflictColumns: conflictColumns(HouseholdMember.t),
      updateColumns: updateColumns?.call(HouseholdMember.t),
      updateWhere: updateWhere?.call(HouseholdMember.t),
      transaction: transaction,
    );
  }

  /// Updates all [HouseholdMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<HouseholdMember>> update(
    _is.DatabaseSession session,
    List<HouseholdMember> rows, {
    _is.ColumnSelections<HouseholdMemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<HouseholdMember>(
      rows,
      columns: columns?.call(HouseholdMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [HouseholdMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<HouseholdMember> updateRow(
    _is.DatabaseSession session,
    HouseholdMember row, {
    _is.ColumnSelections<HouseholdMemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<HouseholdMember>(
      row,
      columns: columns?.call(HouseholdMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HouseholdMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<HouseholdMember?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<HouseholdMemberUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<HouseholdMember>(
      id,
      columnValues: columnValues(HouseholdMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [HouseholdMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<HouseholdMember>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<HouseholdMemberUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<HouseholdMemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<HouseholdMemberTable>? orderBy,
    _is.OrderByListBuilder<HouseholdMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<HouseholdMember>(
      columnValues: columnValues(HouseholdMember.t.updateTable),
      where: where(HouseholdMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HouseholdMember.t),
      orderByList: orderByList?.call(HouseholdMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [HouseholdMember]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<HouseholdMember>> delete(
    _is.DatabaseSession session,
    List<HouseholdMember> rows, {
    _is.OrderByBuilder<HouseholdMemberTable>? orderBy,
    _is.OrderByListBuilder<HouseholdMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<HouseholdMember>(
      rows,
      orderBy: orderBy?.call(HouseholdMember.t),
      orderByList: orderByList?.call(HouseholdMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [HouseholdMember].
  Future<HouseholdMember> deleteRow(
    _is.DatabaseSession session,
    HouseholdMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<HouseholdMember>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<HouseholdMember>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<HouseholdMemberTable> where,
    _is.OrderByBuilder<HouseholdMemberTable>? orderBy,
    _is.OrderByListBuilder<HouseholdMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<HouseholdMember>(
      where: where(HouseholdMember.t),
      orderBy: orderBy?.call(HouseholdMember.t),
      orderByList: orderByList?.call(HouseholdMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<HouseholdMemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<HouseholdMember>(
      where: where?.call(HouseholdMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [HouseholdMember] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<HouseholdMemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<HouseholdMember>(
      where: where(HouseholdMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
