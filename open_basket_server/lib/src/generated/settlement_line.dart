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

/// Who owes whom after a run. Immutable once written.
abstract class SettlementLine
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SettlementLine._({
    this.id,
    required this.basketId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amountMinor,
    required this.itemsMinor,
    required this.receiptGapMinor,
  });

  factory SettlementLine({
    int? id,
    required int basketId,
    required int fromMemberId,
    required int toMemberId,
    required int amountMinor,
    required int itemsMinor,
    required int receiptGapMinor,
  }) = _SettlementLineImpl;

  factory SettlementLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return SettlementLine(
      id: jsonSerialization['id'] as int?,
      basketId: jsonSerialization['basketId'] as int,
      fromMemberId: jsonSerialization['fromMemberId'] as int,
      toMemberId: jsonSerialization['toMemberId'] as int,
      amountMinor: jsonSerialization['amountMinor'] as int,
      itemsMinor: jsonSerialization['itemsMinor'] as int,
      receiptGapMinor: jsonSerialization['receiptGapMinor'] as int,
    );
  }

  static final t = SettlementLineTable();

  static const db = SettlementLineRepository._();

  @override
  int? id;

  int basketId;

  int fromMemberId;

  int toMemberId;

  /// Total owed, in minor units: own picked items plus a share of the gap.
  int amountMinor;

  /// The two terms above, kept separately so the UI can show
  /// "₺84.50 items + ₺0.50 gap" without recomputing (ADR-007).
  int itemsMinor;

  int receiptGapMinor;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SettlementLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SettlementLine copyWith({
    int? id,
    int? basketId,
    int? fromMemberId,
    int? toMemberId,
    int? amountMinor,
    int? itemsMinor,
    int? receiptGapMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SettlementLine',
      if (id != null) 'id': id,
      'basketId': basketId,
      'fromMemberId': fromMemberId,
      'toMemberId': toMemberId,
      'amountMinor': amountMinor,
      'itemsMinor': itemsMinor,
      'receiptGapMinor': receiptGapMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SettlementLine',
      if (id != null) 'id': id,
      'basketId': basketId,
      'fromMemberId': fromMemberId,
      'toMemberId': toMemberId,
      'amountMinor': amountMinor,
      'itemsMinor': itemsMinor,
      'receiptGapMinor': receiptGapMinor,
    };
  }

  static SettlementLineInclude include() {
    return SettlementLineInclude._();
  }

  static SettlementLineIncludeList includeList({
    _is.WhereExpressionBuilder<SettlementLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SettlementLineTable>? orderBy,
    _is.OrderByListBuilder<SettlementLineTable>? orderByList,
    SettlementLineInclude? include,
  }) {
    return SettlementLineIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SettlementLine.t),
      orderByList: orderByList?.call(SettlementLine.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SettlementLineImpl extends SettlementLine {
  _SettlementLineImpl({
    int? id,
    required int basketId,
    required int fromMemberId,
    required int toMemberId,
    required int amountMinor,
    required int itemsMinor,
    required int receiptGapMinor,
  }) : super._(
         id: id,
         basketId: basketId,
         fromMemberId: fromMemberId,
         toMemberId: toMemberId,
         amountMinor: amountMinor,
         itemsMinor: itemsMinor,
         receiptGapMinor: receiptGapMinor,
       );

  /// Returns a shallow copy of this [SettlementLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SettlementLine copyWith({
    Object? id = _Undefined,
    int? basketId,
    int? fromMemberId,
    int? toMemberId,
    int? amountMinor,
    int? itemsMinor,
    int? receiptGapMinor,
  }) {
    return SettlementLine(
      id: id is int? ? id : this.id,
      basketId: basketId ?? this.basketId,
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      amountMinor: amountMinor ?? this.amountMinor,
      itemsMinor: itemsMinor ?? this.itemsMinor,
      receiptGapMinor: receiptGapMinor ?? this.receiptGapMinor,
    );
  }
}

class SettlementLineUpdateTable extends _is.UpdateTable<SettlementLineTable> {
  SettlementLineUpdateTable(super.table);

  _is.ColumnValue<int, int> basketId(int value) => _is.ColumnValue(
    table.basketId,
    value,
  );

  _is.ColumnValue<int, int> fromMemberId(int value) => _is.ColumnValue(
    table.fromMemberId,
    value,
  );

  _is.ColumnValue<int, int> toMemberId(int value) => _is.ColumnValue(
    table.toMemberId,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<int, int> itemsMinor(int value) => _is.ColumnValue(
    table.itemsMinor,
    value,
  );

  _is.ColumnValue<int, int> receiptGapMinor(int value) => _is.ColumnValue(
    table.receiptGapMinor,
    value,
  );
}

class SettlementLineTable extends _is.Table<int?> {
  SettlementLineTable({super.tableRelation})
    : super(tableName: 'settlement_line') {
    updateTable = SettlementLineUpdateTable(this);
    basketId = _is.ColumnInt(
      'basketId',
      this,
    );
    fromMemberId = _is.ColumnInt(
      'fromMemberId',
      this,
    );
    toMemberId = _is.ColumnInt(
      'toMemberId',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    itemsMinor = _is.ColumnInt(
      'itemsMinor',
      this,
    );
    receiptGapMinor = _is.ColumnInt(
      'receiptGapMinor',
      this,
    );
  }

  late final SettlementLineUpdateTable updateTable;

  late final _is.ColumnInt basketId;

  late final _is.ColumnInt fromMemberId;

  late final _is.ColumnInt toMemberId;

  /// Total owed, in minor units: own picked items plus a share of the gap.
  late final _is.ColumnInt amountMinor;

  /// The two terms above, kept separately so the UI can show
  /// "₺84.50 items + ₺0.50 gap" without recomputing (ADR-007).
  late final _is.ColumnInt itemsMinor;

  late final _is.ColumnInt receiptGapMinor;

  @override
  List<_is.Column> get columns => [
    id,
    basketId,
    fromMemberId,
    toMemberId,
    amountMinor,
    itemsMinor,
    receiptGapMinor,
  ];
}

class SettlementLineInclude extends _is.IncludeObject {
  SettlementLineInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SettlementLine.t;
}

class SettlementLineIncludeList extends _is.IncludeList {
  SettlementLineIncludeList._({
    _is.WhereExpressionBuilder<SettlementLineTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SettlementLine.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SettlementLine.t;
}

class SettlementLineRepository {
  const SettlementLineRepository._();

  /// Returns a list of [SettlementLine]s matching the given query parameters.
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
  Future<List<SettlementLine>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SettlementLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SettlementLineTable>? orderBy,
    _is.OrderByListBuilder<SettlementLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SettlementLine>(
      where: where?.call(SettlementLine.t),
      orderBy: orderBy?.call(SettlementLine.t),
      orderByList: orderByList?.call(SettlementLine.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SettlementLine] matching the given query parameters.
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
  Future<SettlementLine?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SettlementLineTable>? where,
    int? offset,
    _is.OrderByBuilder<SettlementLineTable>? orderBy,
    _is.OrderByListBuilder<SettlementLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SettlementLine>(
      where: where?.call(SettlementLine.t),
      orderBy: orderBy?.call(SettlementLine.t),
      orderByList: orderByList?.call(SettlementLine.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SettlementLine] by its [id] or null if no such row exists.
  Future<SettlementLine?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SettlementLine>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SettlementLine]s in the list and returns the inserted rows.
  ///
  /// The returned [SettlementLine]s will have their `id` fields set.
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
  Future<List<SettlementLine>> insert(
    _is.DatabaseSession session,
    List<SettlementLine> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SettlementLine>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SettlementLine] and returns the inserted row.
  ///
  /// The returned [SettlementLine] will have its `id` field set.
  Future<SettlementLine> insertRow(
    _is.DatabaseSession session,
    SettlementLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SettlementLine>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SettlementLine]s in the list and returns the resulting rows.
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
  /// The returned [SettlementLine]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SettlementLine>> upsert(
    _is.DatabaseSession session,
    List<SettlementLine> rows, {
    required _is.ColumnSelections<SettlementLineTable> conflictColumns,
    _is.ColumnSelections<SettlementLineTable>? updateColumns,
    _is.WhereExpressionBuilder<SettlementLineTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SettlementLine>(
      rows,
      conflictColumns: conflictColumns(SettlementLine.t),
      updateColumns: updateColumns?.call(SettlementLine.t),
      updateWhere: updateWhere?.call(SettlementLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SettlementLine] and returns the resulting row.
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
  /// The returned [SettlementLine] will have its `id` field set.
  Future<SettlementLine?> upsertRow(
    _is.DatabaseSession session,
    SettlementLine row, {
    required _is.ColumnSelections<SettlementLineTable> conflictColumns,
    _is.ColumnSelections<SettlementLineTable>? updateColumns,
    _is.WhereExpressionBuilder<SettlementLineTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SettlementLine>(
      row,
      conflictColumns: conflictColumns(SettlementLine.t),
      updateColumns: updateColumns?.call(SettlementLine.t),
      updateWhere: updateWhere?.call(SettlementLine.t),
      transaction: transaction,
    );
  }

  /// Updates all [SettlementLine]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SettlementLine>> update(
    _is.DatabaseSession session,
    List<SettlementLine> rows, {
    _is.ColumnSelections<SettlementLineTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SettlementLine>(
      rows,
      columns: columns?.call(SettlementLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SettlementLine]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SettlementLine> updateRow(
    _is.DatabaseSession session,
    SettlementLine row, {
    _is.ColumnSelections<SettlementLineTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SettlementLine>(
      row,
      columns: columns?.call(SettlementLine.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SettlementLine] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SettlementLine?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SettlementLineUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SettlementLine>(
      id,
      columnValues: columnValues(SettlementLine.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SettlementLine]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SettlementLine>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SettlementLineUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SettlementLineTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SettlementLineTable>? orderBy,
    _is.OrderByListBuilder<SettlementLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SettlementLine>(
      columnValues: columnValues(SettlementLine.t.updateTable),
      where: where(SettlementLine.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SettlementLine.t),
      orderByList: orderByList?.call(SettlementLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SettlementLine]s in the list and returns the deleted rows.
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
  Future<List<SettlementLine>> delete(
    _is.DatabaseSession session,
    List<SettlementLine> rows, {
    _is.OrderByBuilder<SettlementLineTable>? orderBy,
    _is.OrderByListBuilder<SettlementLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SettlementLine>(
      rows,
      orderBy: orderBy?.call(SettlementLine.t),
      orderByList: orderByList?.call(SettlementLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SettlementLine].
  Future<SettlementLine> deleteRow(
    _is.DatabaseSession session,
    SettlementLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SettlementLine>(
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
  Future<List<SettlementLine>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SettlementLineTable> where,
    _is.OrderByBuilder<SettlementLineTable>? orderBy,
    _is.OrderByListBuilder<SettlementLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SettlementLine>(
      where: where(SettlementLine.t),
      orderBy: orderBy?.call(SettlementLine.t),
      orderByList: orderByList?.call(SettlementLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SettlementLineTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SettlementLine>(
      where: where?.call(SettlementLine.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SettlementLine] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SettlementLineTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SettlementLine>(
      where: where(SettlementLine.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
