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

/// One failed attempt to join with a code (ADR-045). A six-character code is
/// the only thing between a stranger and a household, so wrong guesses are
/// counted per account and capped.
abstract class JoinAttempt
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  JoinAttempt._({
    this.id,
    required this.userId,
    required this.attemptedAt,
  });

  factory JoinAttempt({
    int? id,
    required _is.UuidValue userId,
    required DateTime attemptedAt,
  }) = _JoinAttemptImpl;

  factory JoinAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return JoinAttempt(
      id: jsonSerialization['id'] as int?,
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      attemptedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['attemptedAt'],
      ),
    );
  }

  static final t = JoinAttemptTable();

  static const db = JoinAttemptRepository._();

  @override
  int? id;

  _is.UuidValue userId;

  DateTime attemptedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [JoinAttempt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  JoinAttempt copyWith({
    int? id,
    _is.UuidValue? userId,
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

  static JoinAttemptInclude include() {
    return JoinAttemptInclude._();
  }

  static JoinAttemptIncludeList includeList({
    _is.WhereExpressionBuilder<JoinAttemptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JoinAttemptTable>? orderBy,
    _is.OrderByListBuilder<JoinAttemptTable>? orderByList,
    JoinAttemptInclude? include,
  }) {
    return JoinAttemptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JoinAttempt.t),
      orderByList: orderByList?.call(JoinAttempt.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JoinAttemptImpl extends JoinAttempt {
  _JoinAttemptImpl({
    int? id,
    required _is.UuidValue userId,
    required DateTime attemptedAt,
  }) : super._(
         id: id,
         userId: userId,
         attemptedAt: attemptedAt,
       );

  /// Returns a shallow copy of this [JoinAttempt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  JoinAttempt copyWith({
    Object? id = _Undefined,
    _is.UuidValue? userId,
    DateTime? attemptedAt,
  }) {
    return JoinAttempt(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      attemptedAt: attemptedAt ?? this.attemptedAt,
    );
  }
}

class JoinAttemptUpdateTable extends _is.UpdateTable<JoinAttemptTable> {
  JoinAttemptUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> attemptedAt(DateTime value) =>
      _is.ColumnValue(
        table.attemptedAt,
        value,
      );
}

class JoinAttemptTable extends _is.Table<int?> {
  JoinAttemptTable({super.tableRelation}) : super(tableName: 'join_attempt') {
    updateTable = JoinAttemptUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    attemptedAt = _is.ColumnDateTime(
      'attemptedAt',
      this,
    );
  }

  late final JoinAttemptUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnDateTime attemptedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    attemptedAt,
  ];
}

class JoinAttemptInclude extends _is.IncludeObject {
  JoinAttemptInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => JoinAttempt.t;
}

class JoinAttemptIncludeList extends _is.IncludeList {
  JoinAttemptIncludeList._({
    _is.WhereExpressionBuilder<JoinAttemptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(JoinAttempt.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => JoinAttempt.t;
}

class JoinAttemptRepository {
  const JoinAttemptRepository._();

  /// Returns a list of [JoinAttempt]s matching the given query parameters.
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
  Future<List<JoinAttempt>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JoinAttemptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JoinAttemptTable>? orderBy,
    _is.OrderByListBuilder<JoinAttemptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<JoinAttempt>(
      where: where?.call(JoinAttempt.t),
      orderBy: orderBy?.call(JoinAttempt.t),
      orderByList: orderByList?.call(JoinAttempt.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [JoinAttempt] matching the given query parameters.
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
  Future<JoinAttempt?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JoinAttemptTable>? where,
    int? offset,
    _is.OrderByBuilder<JoinAttemptTable>? orderBy,
    _is.OrderByListBuilder<JoinAttemptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<JoinAttempt>(
      where: where?.call(JoinAttempt.t),
      orderBy: orderBy?.call(JoinAttempt.t),
      orderByList: orderByList?.call(JoinAttempt.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [JoinAttempt] by its [id] or null if no such row exists.
  Future<JoinAttempt?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<JoinAttempt>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [JoinAttempt]s in the list and returns the inserted rows.
  ///
  /// The returned [JoinAttempt]s will have their `id` fields set.
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
  Future<List<JoinAttempt>> insert(
    _is.DatabaseSession session,
    List<JoinAttempt> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<JoinAttempt>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [JoinAttempt] and returns the inserted row.
  ///
  /// The returned [JoinAttempt] will have its `id` field set.
  Future<JoinAttempt> insertRow(
    _is.DatabaseSession session,
    JoinAttempt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<JoinAttempt>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [JoinAttempt]s in the list and returns the resulting rows.
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
  /// The returned [JoinAttempt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<JoinAttempt>> upsert(
    _is.DatabaseSession session,
    List<JoinAttempt> rows, {
    required _is.ColumnSelections<JoinAttemptTable> conflictColumns,
    _is.ColumnSelections<JoinAttemptTable>? updateColumns,
    _is.WhereExpressionBuilder<JoinAttemptTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<JoinAttempt>(
      rows,
      conflictColumns: conflictColumns(JoinAttempt.t),
      updateColumns: updateColumns?.call(JoinAttempt.t),
      updateWhere: updateWhere?.call(JoinAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [JoinAttempt] and returns the resulting row.
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
  /// The returned [JoinAttempt] will have its `id` field set.
  Future<JoinAttempt?> upsertRow(
    _is.DatabaseSession session,
    JoinAttempt row, {
    required _is.ColumnSelections<JoinAttemptTable> conflictColumns,
    _is.ColumnSelections<JoinAttemptTable>? updateColumns,
    _is.WhereExpressionBuilder<JoinAttemptTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<JoinAttempt>(
      row,
      conflictColumns: conflictColumns(JoinAttempt.t),
      updateColumns: updateColumns?.call(JoinAttempt.t),
      updateWhere: updateWhere?.call(JoinAttempt.t),
      transaction: transaction,
    );
  }

  /// Updates all [JoinAttempt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<JoinAttempt>> update(
    _is.DatabaseSession session,
    List<JoinAttempt> rows, {
    _is.ColumnSelections<JoinAttemptTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<JoinAttempt>(
      rows,
      columns: columns?.call(JoinAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [JoinAttempt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<JoinAttempt> updateRow(
    _is.DatabaseSession session,
    JoinAttempt row, {
    _is.ColumnSelections<JoinAttemptTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<JoinAttempt>(
      row,
      columns: columns?.call(JoinAttempt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [JoinAttempt] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<JoinAttempt?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<JoinAttemptUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<JoinAttempt>(
      id,
      columnValues: columnValues(JoinAttempt.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [JoinAttempt]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<JoinAttempt>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<JoinAttemptUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<JoinAttemptTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JoinAttemptTable>? orderBy,
    _is.OrderByListBuilder<JoinAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<JoinAttempt>(
      columnValues: columnValues(JoinAttempt.t.updateTable),
      where: where(JoinAttempt.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JoinAttempt.t),
      orderByList: orderByList?.call(JoinAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [JoinAttempt]s in the list and returns the deleted rows.
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
  Future<List<JoinAttempt>> delete(
    _is.DatabaseSession session,
    List<JoinAttempt> rows, {
    _is.OrderByBuilder<JoinAttemptTable>? orderBy,
    _is.OrderByListBuilder<JoinAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<JoinAttempt>(
      rows,
      orderBy: orderBy?.call(JoinAttempt.t),
      orderByList: orderByList?.call(JoinAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [JoinAttempt].
  Future<JoinAttempt> deleteRow(
    _is.DatabaseSession session,
    JoinAttempt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<JoinAttempt>(
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
  Future<List<JoinAttempt>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<JoinAttemptTable> where,
    _is.OrderByBuilder<JoinAttemptTable>? orderBy,
    _is.OrderByListBuilder<JoinAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<JoinAttempt>(
      where: where(JoinAttempt.t),
      orderBy: orderBy?.call(JoinAttempt.t),
      orderByList: orderByList?.call(JoinAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JoinAttemptTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<JoinAttempt>(
      where: where?.call(JoinAttempt.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [JoinAttempt] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<JoinAttemptTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<JoinAttempt>(
      where: where(JoinAttempt.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
