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

/// A six-digit sign-in code (ADR-004). Server-only: the code must never be
/// serialized to a client.
///
/// Policy: expires 10 minutes after issue, 3 attempts, and issuing a new code
/// for an address invalidates every earlier one.
abstract class SignInCode
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SignInCode._({
    this.id,
    required this.email,
    required this.codeHash,
    required this.expiresAt,
    int? attemptsRemaining,
    this.consumedAt,
    DateTime? createdAt,
  }) : attemptsRemaining = attemptsRemaining ?? 3,
       createdAt = createdAt ?? DateTime.now();

  factory SignInCode({
    int? id,
    required String email,
    required String codeHash,
    required DateTime expiresAt,
    int? attemptsRemaining,
    DateTime? consumedAt,
    DateTime? createdAt,
  }) = _SignInCodeImpl;

  factory SignInCode.fromJson(Map<String, dynamic> jsonSerialization) {
    return SignInCode(
      id: jsonSerialization['id'] as int?,
      email: jsonSerialization['email'] as String,
      codeHash: jsonSerialization['codeHash'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      attemptsRemaining: jsonSerialization['attemptsRemaining'] as int?,
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SignInCodeTable();

  static const db = SignInCodeRepository._();

  @override
  int? id;

  String email;

  /// Hashed, never stored in the clear.
  String codeHash;

  DateTime expiresAt;

  int attemptsRemaining;

  DateTime? consumedAt;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SignInCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SignInCode copyWith({
    int? id,
    String? email,
    String? codeHash,
    DateTime? expiresAt,
    int? attemptsRemaining,
    DateTime? consumedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SignInCode',
      if (id != null) 'id': id,
      'email': email,
      'codeHash': codeHash,
      'expiresAt': expiresAt.toJson(),
      'attemptsRemaining': attemptsRemaining,
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SignInCodeInclude include() {
    return SignInCodeInclude._();
  }

  static SignInCodeIncludeList includeList({
    _is.WhereExpressionBuilder<SignInCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SignInCodeTable>? orderBy,
    _is.OrderByListBuilder<SignInCodeTable>? orderByList,
    SignInCodeInclude? include,
  }) {
    return SignInCodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SignInCode.t),
      orderByList: orderByList?.call(SignInCode.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SignInCodeImpl extends SignInCode {
  _SignInCodeImpl({
    int? id,
    required String email,
    required String codeHash,
    required DateTime expiresAt,
    int? attemptsRemaining,
    DateTime? consumedAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         email: email,
         codeHash: codeHash,
         expiresAt: expiresAt,
         attemptsRemaining: attemptsRemaining,
         consumedAt: consumedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SignInCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SignInCode copyWith({
    Object? id = _Undefined,
    String? email,
    String? codeHash,
    DateTime? expiresAt,
    int? attemptsRemaining,
    Object? consumedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return SignInCode(
      id: id is int? ? id : this.id,
      email: email ?? this.email,
      codeHash: codeHash ?? this.codeHash,
      expiresAt: expiresAt ?? this.expiresAt,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SignInCodeUpdateTable extends _is.UpdateTable<SignInCodeTable> {
  SignInCodeUpdateTable(super.table);

  _is.ColumnValue<String, String> email(String value) => _is.ColumnValue(
    table.email,
    value,
  );

  _is.ColumnValue<String, String> codeHash(String value) => _is.ColumnValue(
    table.codeHash,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<int, int> attemptsRemaining(int value) => _is.ColumnValue(
    table.attemptsRemaining,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> consumedAt(DateTime? value) =>
      _is.ColumnValue(
        table.consumedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SignInCodeTable extends _is.Table<int?> {
  SignInCodeTable({super.tableRelation}) : super(tableName: 'sign_in_code') {
    updateTable = SignInCodeUpdateTable(this);
    email = _is.ColumnString(
      'email',
      this,
    );
    codeHash = _is.ColumnString(
      'codeHash',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    attemptsRemaining = _is.ColumnInt(
      'attemptsRemaining',
      this,
      hasDefault: true,
    );
    consumedAt = _is.ColumnDateTime(
      'consumedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final SignInCodeUpdateTable updateTable;

  late final _is.ColumnString email;

  /// Hashed, never stored in the clear.
  late final _is.ColumnString codeHash;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnInt attemptsRemaining;

  late final _is.ColumnDateTime consumedAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    email,
    codeHash,
    expiresAt,
    attemptsRemaining,
    consumedAt,
    createdAt,
  ];
}

class SignInCodeInclude extends _is.IncludeObject {
  SignInCodeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SignInCode.t;
}

class SignInCodeIncludeList extends _is.IncludeList {
  SignInCodeIncludeList._({
    _is.WhereExpressionBuilder<SignInCodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SignInCode.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SignInCode.t;
}

class SignInCodeRepository {
  const SignInCodeRepository._();

  /// Returns a list of [SignInCode]s matching the given query parameters.
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
  Future<List<SignInCode>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SignInCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SignInCodeTable>? orderBy,
    _is.OrderByListBuilder<SignInCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SignInCode>(
      where: where?.call(SignInCode.t),
      orderBy: orderBy?.call(SignInCode.t),
      orderByList: orderByList?.call(SignInCode.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SignInCode] matching the given query parameters.
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
  Future<SignInCode?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SignInCodeTable>? where,
    int? offset,
    _is.OrderByBuilder<SignInCodeTable>? orderBy,
    _is.OrderByListBuilder<SignInCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SignInCode>(
      where: where?.call(SignInCode.t),
      orderBy: orderBy?.call(SignInCode.t),
      orderByList: orderByList?.call(SignInCode.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SignInCode] by its [id] or null if no such row exists.
  Future<SignInCode?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SignInCode>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SignInCode]s in the list and returns the inserted rows.
  ///
  /// The returned [SignInCode]s will have their `id` fields set.
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
  Future<List<SignInCode>> insert(
    _is.DatabaseSession session,
    List<SignInCode> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SignInCode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SignInCode] and returns the inserted row.
  ///
  /// The returned [SignInCode] will have its `id` field set.
  Future<SignInCode> insertRow(
    _is.DatabaseSession session,
    SignInCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SignInCode>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SignInCode]s in the list and returns the resulting rows.
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
  /// The returned [SignInCode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SignInCode>> upsert(
    _is.DatabaseSession session,
    List<SignInCode> rows, {
    required _is.ColumnSelections<SignInCodeTable> conflictColumns,
    _is.ColumnSelections<SignInCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<SignInCodeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SignInCode>(
      rows,
      conflictColumns: conflictColumns(SignInCode.t),
      updateColumns: updateColumns?.call(SignInCode.t),
      updateWhere: updateWhere?.call(SignInCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SignInCode] and returns the resulting row.
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
  /// The returned [SignInCode] will have its `id` field set.
  Future<SignInCode?> upsertRow(
    _is.DatabaseSession session,
    SignInCode row, {
    required _is.ColumnSelections<SignInCodeTable> conflictColumns,
    _is.ColumnSelections<SignInCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<SignInCodeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SignInCode>(
      row,
      conflictColumns: conflictColumns(SignInCode.t),
      updateColumns: updateColumns?.call(SignInCode.t),
      updateWhere: updateWhere?.call(SignInCode.t),
      transaction: transaction,
    );
  }

  /// Updates all [SignInCode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SignInCode>> update(
    _is.DatabaseSession session,
    List<SignInCode> rows, {
    _is.ColumnSelections<SignInCodeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SignInCode>(
      rows,
      columns: columns?.call(SignInCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SignInCode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SignInCode> updateRow(
    _is.DatabaseSession session,
    SignInCode row, {
    _is.ColumnSelections<SignInCodeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SignInCode>(
      row,
      columns: columns?.call(SignInCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SignInCode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SignInCode?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SignInCodeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SignInCode>(
      id,
      columnValues: columnValues(SignInCode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SignInCode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SignInCode>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SignInCodeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SignInCodeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SignInCodeTable>? orderBy,
    _is.OrderByListBuilder<SignInCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SignInCode>(
      columnValues: columnValues(SignInCode.t.updateTable),
      where: where(SignInCode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SignInCode.t),
      orderByList: orderByList?.call(SignInCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SignInCode]s in the list and returns the deleted rows.
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
  Future<List<SignInCode>> delete(
    _is.DatabaseSession session,
    List<SignInCode> rows, {
    _is.OrderByBuilder<SignInCodeTable>? orderBy,
    _is.OrderByListBuilder<SignInCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SignInCode>(
      rows,
      orderBy: orderBy?.call(SignInCode.t),
      orderByList: orderByList?.call(SignInCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SignInCode].
  Future<SignInCode> deleteRow(
    _is.DatabaseSession session,
    SignInCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SignInCode>(
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
  Future<List<SignInCode>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SignInCodeTable> where,
    _is.OrderByBuilder<SignInCodeTable>? orderBy,
    _is.OrderByListBuilder<SignInCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SignInCode>(
      where: where(SignInCode.t),
      orderBy: orderBy?.call(SignInCode.t),
      orderByList: orderByList?.call(SignInCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SignInCodeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SignInCode>(
      where: where?.call(SignInCode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SignInCode] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SignInCodeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SignInCode>(
      where: where(SignInCode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
