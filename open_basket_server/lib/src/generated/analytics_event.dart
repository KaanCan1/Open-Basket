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

/// Every key event lands here. The Day 26 report is built from this table, so
/// a metric added later is data already lost.
abstract class AnalyticsEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AnalyticsEventTable();

  static const db = AnalyticsEventRepository._();

  @override
  int? id;

  String type;

  int? householdId;

  int? basketId;

  int? memberId;

  /// JSON blob, free shape per event type.
  String? payload;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AnalyticsEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static AnalyticsEventInclude include() {
    return AnalyticsEventInclude._();
  }

  static AnalyticsEventIncludeList includeList({
    _is.WhereExpressionBuilder<AnalyticsEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnalyticsEventTable>? orderBy,
    _is.OrderByListBuilder<AnalyticsEventTable>? orderByList,
    AnalyticsEventInclude? include,
  }) {
    return AnalyticsEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnalyticsEvent.t),
      orderByList: orderByList?.call(AnalyticsEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class AnalyticsEventUpdateTable extends _is.UpdateTable<AnalyticsEventTable> {
  AnalyticsEventUpdateTable(super.table);

  _is.ColumnValue<String, String> type(String value) => _is.ColumnValue(
    table.type,
    value,
  );

  _is.ColumnValue<int, int> householdId(int? value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<int, int> basketId(int? value) => _is.ColumnValue(
    table.basketId,
    value,
  );

  _is.ColumnValue<int, int> memberId(int? value) => _is.ColumnValue(
    table.memberId,
    value,
  );

  _is.ColumnValue<String, String> payload(String? value) => _is.ColumnValue(
    table.payload,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AnalyticsEventTable extends _is.Table<int?> {
  AnalyticsEventTable({super.tableRelation})
    : super(tableName: 'analytics_event') {
    updateTable = AnalyticsEventUpdateTable(this);
    type = _is.ColumnString(
      'type',
      this,
    );
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    basketId = _is.ColumnInt(
      'basketId',
      this,
    );
    memberId = _is.ColumnInt(
      'memberId',
      this,
    );
    payload = _is.ColumnString(
      'payload',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AnalyticsEventUpdateTable updateTable;

  late final _is.ColumnString type;

  late final _is.ColumnInt householdId;

  late final _is.ColumnInt basketId;

  late final _is.ColumnInt memberId;

  /// JSON blob, free shape per event type.
  late final _is.ColumnString payload;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    type,
    householdId,
    basketId,
    memberId,
    payload,
    createdAt,
  ];
}

class AnalyticsEventInclude extends _is.IncludeObject {
  AnalyticsEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AnalyticsEvent.t;
}

class AnalyticsEventIncludeList extends _is.IncludeList {
  AnalyticsEventIncludeList._({
    _is.WhereExpressionBuilder<AnalyticsEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AnalyticsEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AnalyticsEvent.t;
}

class AnalyticsEventRepository {
  const AnalyticsEventRepository._();

  /// Returns a list of [AnalyticsEvent]s matching the given query parameters.
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
  Future<List<AnalyticsEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnalyticsEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnalyticsEventTable>? orderBy,
    _is.OrderByListBuilder<AnalyticsEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AnalyticsEvent>(
      where: where?.call(AnalyticsEvent.t),
      orderBy: orderBy?.call(AnalyticsEvent.t),
      orderByList: orderByList?.call(AnalyticsEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AnalyticsEvent] matching the given query parameters.
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
  Future<AnalyticsEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnalyticsEventTable>? where,
    int? offset,
    _is.OrderByBuilder<AnalyticsEventTable>? orderBy,
    _is.OrderByListBuilder<AnalyticsEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AnalyticsEvent>(
      where: where?.call(AnalyticsEvent.t),
      orderBy: orderBy?.call(AnalyticsEvent.t),
      orderByList: orderByList?.call(AnalyticsEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AnalyticsEvent] by its [id] or null if no such row exists.
  Future<AnalyticsEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AnalyticsEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AnalyticsEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [AnalyticsEvent]s will have their `id` fields set.
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
  Future<List<AnalyticsEvent>> insert(
    _is.DatabaseSession session,
    List<AnalyticsEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AnalyticsEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AnalyticsEvent] and returns the inserted row.
  ///
  /// The returned [AnalyticsEvent] will have its `id` field set.
  Future<AnalyticsEvent> insertRow(
    _is.DatabaseSession session,
    AnalyticsEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AnalyticsEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AnalyticsEvent]s in the list and returns the resulting rows.
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
  /// The returned [AnalyticsEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnalyticsEvent>> upsert(
    _is.DatabaseSession session,
    List<AnalyticsEvent> rows, {
    required _is.ColumnSelections<AnalyticsEventTable> conflictColumns,
    _is.ColumnSelections<AnalyticsEventTable>? updateColumns,
    _is.WhereExpressionBuilder<AnalyticsEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AnalyticsEvent>(
      rows,
      conflictColumns: conflictColumns(AnalyticsEvent.t),
      updateColumns: updateColumns?.call(AnalyticsEvent.t),
      updateWhere: updateWhere?.call(AnalyticsEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AnalyticsEvent] and returns the resulting row.
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
  /// The returned [AnalyticsEvent] will have its `id` field set.
  Future<AnalyticsEvent?> upsertRow(
    _is.DatabaseSession session,
    AnalyticsEvent row, {
    required _is.ColumnSelections<AnalyticsEventTable> conflictColumns,
    _is.ColumnSelections<AnalyticsEventTable>? updateColumns,
    _is.WhereExpressionBuilder<AnalyticsEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AnalyticsEvent>(
      row,
      conflictColumns: conflictColumns(AnalyticsEvent.t),
      updateColumns: updateColumns?.call(AnalyticsEvent.t),
      updateWhere: updateWhere?.call(AnalyticsEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [AnalyticsEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnalyticsEvent>> update(
    _is.DatabaseSession session,
    List<AnalyticsEvent> rows, {
    _is.ColumnSelections<AnalyticsEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AnalyticsEvent>(
      rows,
      columns: columns?.call(AnalyticsEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AnalyticsEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AnalyticsEvent> updateRow(
    _is.DatabaseSession session,
    AnalyticsEvent row, {
    _is.ColumnSelections<AnalyticsEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AnalyticsEvent>(
      row,
      columns: columns?.call(AnalyticsEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AnalyticsEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AnalyticsEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AnalyticsEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AnalyticsEvent>(
      id,
      columnValues: columnValues(AnalyticsEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AnalyticsEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnalyticsEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AnalyticsEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AnalyticsEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnalyticsEventTable>? orderBy,
    _is.OrderByListBuilder<AnalyticsEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AnalyticsEvent>(
      columnValues: columnValues(AnalyticsEvent.t.updateTable),
      where: where(AnalyticsEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnalyticsEvent.t),
      orderByList: orderByList?.call(AnalyticsEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AnalyticsEvent]s in the list and returns the deleted rows.
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
  Future<List<AnalyticsEvent>> delete(
    _is.DatabaseSession session,
    List<AnalyticsEvent> rows, {
    _is.OrderByBuilder<AnalyticsEventTable>? orderBy,
    _is.OrderByListBuilder<AnalyticsEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AnalyticsEvent>(
      rows,
      orderBy: orderBy?.call(AnalyticsEvent.t),
      orderByList: orderByList?.call(AnalyticsEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AnalyticsEvent].
  Future<AnalyticsEvent> deleteRow(
    _is.DatabaseSession session,
    AnalyticsEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AnalyticsEvent>(
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
  Future<List<AnalyticsEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnalyticsEventTable> where,
    _is.OrderByBuilder<AnalyticsEventTable>? orderBy,
    _is.OrderByListBuilder<AnalyticsEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AnalyticsEvent>(
      where: where(AnalyticsEvent.t),
      orderBy: orderBy?.call(AnalyticsEvent.t),
      orderByList: orderByList?.call(AnalyticsEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnalyticsEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AnalyticsEvent>(
      where: where?.call(AnalyticsEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AnalyticsEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnalyticsEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AnalyticsEvent>(
      where: where(AnalyticsEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
