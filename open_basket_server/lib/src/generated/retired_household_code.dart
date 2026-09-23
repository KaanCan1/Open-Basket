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

/// A household code that was rotated away (ADR-045). Kept so a join with it
/// can say "that code has been replaced" instead of "no such code", and so it
/// is never handed to another household: a code in an old group chat must
/// not start opening a stranger's house.
abstract class RetiredHouseholdCode
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      retiredAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['retiredAt'],
      ),
    );
  }

  static final t = RetiredHouseholdCodeTable();

  static const db = RetiredHouseholdCodeRepository._();

  @override
  int? id;

  int householdId;

  String code;

  DateTime retiredAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RetiredHouseholdCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static RetiredHouseholdCodeInclude include() {
    return RetiredHouseholdCodeInclude._();
  }

  static RetiredHouseholdCodeIncludeList includeList({
    _is.WhereExpressionBuilder<RetiredHouseholdCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RetiredHouseholdCodeTable>? orderBy,
    _is.OrderByListBuilder<RetiredHouseholdCodeTable>? orderByList,
    RetiredHouseholdCodeInclude? include,
  }) {
    return RetiredHouseholdCodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RetiredHouseholdCode.t),
      orderByList: orderByList?.call(RetiredHouseholdCode.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class RetiredHouseholdCodeUpdateTable
    extends _is.UpdateTable<RetiredHouseholdCodeTable> {
  RetiredHouseholdCodeUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<String, String> code(String value) => _is.ColumnValue(
    table.code,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> retiredAt(DateTime value) =>
      _is.ColumnValue(
        table.retiredAt,
        value,
      );
}

class RetiredHouseholdCodeTable extends _is.Table<int?> {
  RetiredHouseholdCodeTable({super.tableRelation})
    : super(tableName: 'retired_household_code') {
    updateTable = RetiredHouseholdCodeUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    code = _is.ColumnString(
      'code',
      this,
    );
    retiredAt = _is.ColumnDateTime(
      'retiredAt',
      this,
    );
  }

  late final RetiredHouseholdCodeUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  late final _is.ColumnString code;

  late final _is.ColumnDateTime retiredAt;

  @override
  List<_is.Column> get columns => [
    id,
    householdId,
    code,
    retiredAt,
  ];
}

class RetiredHouseholdCodeInclude extends _is.IncludeObject {
  RetiredHouseholdCodeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RetiredHouseholdCode.t;
}

class RetiredHouseholdCodeIncludeList extends _is.IncludeList {
  RetiredHouseholdCodeIncludeList._({
    _is.WhereExpressionBuilder<RetiredHouseholdCodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RetiredHouseholdCode.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RetiredHouseholdCode.t;
}

class RetiredHouseholdCodeRepository {
  const RetiredHouseholdCodeRepository._();

  /// Returns a list of [RetiredHouseholdCode]s matching the given query parameters.
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
  Future<List<RetiredHouseholdCode>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RetiredHouseholdCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RetiredHouseholdCodeTable>? orderBy,
    _is.OrderByListBuilder<RetiredHouseholdCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RetiredHouseholdCode>(
      where: where?.call(RetiredHouseholdCode.t),
      orderBy: orderBy?.call(RetiredHouseholdCode.t),
      orderByList: orderByList?.call(RetiredHouseholdCode.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RetiredHouseholdCode] matching the given query parameters.
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
  Future<RetiredHouseholdCode?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RetiredHouseholdCodeTable>? where,
    int? offset,
    _is.OrderByBuilder<RetiredHouseholdCodeTable>? orderBy,
    _is.OrderByListBuilder<RetiredHouseholdCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RetiredHouseholdCode>(
      where: where?.call(RetiredHouseholdCode.t),
      orderBy: orderBy?.call(RetiredHouseholdCode.t),
      orderByList: orderByList?.call(RetiredHouseholdCode.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RetiredHouseholdCode] by its [id] or null if no such row exists.
  Future<RetiredHouseholdCode?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RetiredHouseholdCode>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RetiredHouseholdCode]s in the list and returns the inserted rows.
  ///
  /// The returned [RetiredHouseholdCode]s will have their `id` fields set.
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
  Future<List<RetiredHouseholdCode>> insert(
    _is.DatabaseSession session,
    List<RetiredHouseholdCode> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RetiredHouseholdCode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RetiredHouseholdCode] and returns the inserted row.
  ///
  /// The returned [RetiredHouseholdCode] will have its `id` field set.
  Future<RetiredHouseholdCode> insertRow(
    _is.DatabaseSession session,
    RetiredHouseholdCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RetiredHouseholdCode>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RetiredHouseholdCode]s in the list and returns the resulting rows.
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
  /// The returned [RetiredHouseholdCode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RetiredHouseholdCode>> upsert(
    _is.DatabaseSession session,
    List<RetiredHouseholdCode> rows, {
    required _is.ColumnSelections<RetiredHouseholdCodeTable> conflictColumns,
    _is.ColumnSelections<RetiredHouseholdCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<RetiredHouseholdCodeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RetiredHouseholdCode>(
      rows,
      conflictColumns: conflictColumns(RetiredHouseholdCode.t),
      updateColumns: updateColumns?.call(RetiredHouseholdCode.t),
      updateWhere: updateWhere?.call(RetiredHouseholdCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RetiredHouseholdCode] and returns the resulting row.
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
  /// The returned [RetiredHouseholdCode] will have its `id` field set.
  Future<RetiredHouseholdCode?> upsertRow(
    _is.DatabaseSession session,
    RetiredHouseholdCode row, {
    required _is.ColumnSelections<RetiredHouseholdCodeTable> conflictColumns,
    _is.ColumnSelections<RetiredHouseholdCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<RetiredHouseholdCodeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RetiredHouseholdCode>(
      row,
      conflictColumns: conflictColumns(RetiredHouseholdCode.t),
      updateColumns: updateColumns?.call(RetiredHouseholdCode.t),
      updateWhere: updateWhere?.call(RetiredHouseholdCode.t),
      transaction: transaction,
    );
  }

  /// Updates all [RetiredHouseholdCode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RetiredHouseholdCode>> update(
    _is.DatabaseSession session,
    List<RetiredHouseholdCode> rows, {
    _is.ColumnSelections<RetiredHouseholdCodeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RetiredHouseholdCode>(
      rows,
      columns: columns?.call(RetiredHouseholdCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RetiredHouseholdCode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RetiredHouseholdCode> updateRow(
    _is.DatabaseSession session,
    RetiredHouseholdCode row, {
    _is.ColumnSelections<RetiredHouseholdCodeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RetiredHouseholdCode>(
      row,
      columns: columns?.call(RetiredHouseholdCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RetiredHouseholdCode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RetiredHouseholdCode?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RetiredHouseholdCodeUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RetiredHouseholdCode>(
      id,
      columnValues: columnValues(RetiredHouseholdCode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RetiredHouseholdCode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RetiredHouseholdCode>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RetiredHouseholdCodeUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RetiredHouseholdCodeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RetiredHouseholdCodeTable>? orderBy,
    _is.OrderByListBuilder<RetiredHouseholdCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RetiredHouseholdCode>(
      columnValues: columnValues(RetiredHouseholdCode.t.updateTable),
      where: where(RetiredHouseholdCode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RetiredHouseholdCode.t),
      orderByList: orderByList?.call(RetiredHouseholdCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RetiredHouseholdCode]s in the list and returns the deleted rows.
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
  Future<List<RetiredHouseholdCode>> delete(
    _is.DatabaseSession session,
    List<RetiredHouseholdCode> rows, {
    _is.OrderByBuilder<RetiredHouseholdCodeTable>? orderBy,
    _is.OrderByListBuilder<RetiredHouseholdCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RetiredHouseholdCode>(
      rows,
      orderBy: orderBy?.call(RetiredHouseholdCode.t),
      orderByList: orderByList?.call(RetiredHouseholdCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RetiredHouseholdCode].
  Future<RetiredHouseholdCode> deleteRow(
    _is.DatabaseSession session,
    RetiredHouseholdCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RetiredHouseholdCode>(
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
  Future<List<RetiredHouseholdCode>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RetiredHouseholdCodeTable> where,
    _is.OrderByBuilder<RetiredHouseholdCodeTable>? orderBy,
    _is.OrderByListBuilder<RetiredHouseholdCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RetiredHouseholdCode>(
      where: where(RetiredHouseholdCode.t),
      orderBy: orderBy?.call(RetiredHouseholdCode.t),
      orderByList: orderByList?.call(RetiredHouseholdCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RetiredHouseholdCodeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RetiredHouseholdCode>(
      where: where?.call(RetiredHouseholdCode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RetiredHouseholdCode] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RetiredHouseholdCodeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RetiredHouseholdCode>(
      where: where(RetiredHouseholdCode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
