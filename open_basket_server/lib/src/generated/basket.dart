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
import 'basket_status.dart' as _iumwz8so;

/// One shopping run. At most one per household may be open at a time.
abstract class Basket implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Basket._({
    this.id,
    required this.householdId,
    required this.shopperMemberId,
    this.storeId,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    required this.closesAt,
    this.frozenAt,
    bool? closedAutomatically,
    int? extendCount,
    this.receiptTotalMinor,
    String? currencyCode,
  }) : status = status ?? _iumwz8so.BasketStatus.open,
       openedAt = openedAt ?? DateTime.now(),
       closedAutomatically = closedAutomatically ?? false,
       extendCount = extendCount ?? 0,
       currencyCode = currencyCode ?? 'TRY';

  factory Basket({
    int? id,
    required int householdId,
    required int shopperMemberId,
    int? storeId,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    required DateTime closesAt,
    DateTime? frozenAt,
    bool? closedAutomatically,
    int? extendCount,
    int? receiptTotalMinor,
    String? currencyCode,
  }) = _BasketImpl;

  factory Basket.fromJson(Map<String, dynamic> jsonSerialization) {
    return Basket(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      shopperMemberId: jsonSerialization['shopperMemberId'] as int,
      storeId: jsonSerialization['storeId'] as int?,
      status: jsonSerialization['status'] == null
          ? null
          : _iumwz8so.BasketStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      openedAt: jsonSerialization['openedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['openedAt']),
      closesAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['closesAt'],
      ),
      frozenAt: jsonSerialization['frozenAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['frozenAt']),
      closedAutomatically: jsonSerialization['closedAutomatically'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['closedAutomatically'],
            ),
      extendCount: jsonSerialization['extendCount'] as int?,
      receiptTotalMinor: jsonSerialization['receiptTotalMinor'] as int?,
      currencyCode: jsonSerialization['currencyCode'] as String?,
    );
  }

  static final t = BasketTable();

  static const db = BasketRepository._();

  @override
  int? id;

  int householdId;

  /// The member doing the shopping. Only they may extend, freeze, mark items,
  /// enter prices, settle or cancel.
  int shopperMemberId;

  int? storeId;

  _iumwz8so.BasketStatus status;

  DateTime openedAt;

  /// The server owns this. The client only renders closesAt - serverNow.
  DateTime closesAt;

  DateTime? frozenAt;

  /// True when the future call closed it rather than the shopper.
  bool closedAutomatically;

  /// One +5 min extension per basket (ADR-009), so this is 0 or 1.
  int extendCount;

  /// What the till actually charged, in minor units. Null until entered.
  int? receiptTotalMinor;

  /// The household's currency at the moment this basket closed. A settled
  /// basket keeps it, so changing the household setting never rewrites history.
  String currencyCode;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Basket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Basket copyWith({
    int? id,
    int? householdId,
    int? shopperMemberId,
    int? storeId,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    DateTime? closesAt,
    DateTime? frozenAt,
    bool? closedAutomatically,
    int? extendCount,
    int? receiptTotalMinor,
    String? currencyCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Basket',
      if (id != null) 'id': id,
      'householdId': householdId,
      'shopperMemberId': shopperMemberId,
      if (storeId != null) 'storeId': storeId,
      'status': status.toJson(),
      'openedAt': openedAt.toJson(),
      'closesAt': closesAt.toJson(),
      if (frozenAt != null) 'frozenAt': frozenAt?.toJson(),
      'closedAutomatically': closedAutomatically,
      'extendCount': extendCount,
      if (receiptTotalMinor != null) 'receiptTotalMinor': receiptTotalMinor,
      'currencyCode': currencyCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Basket',
      if (id != null) 'id': id,
      'householdId': householdId,
      'shopperMemberId': shopperMemberId,
      if (storeId != null) 'storeId': storeId,
      'status': status.toJson(),
      'openedAt': openedAt.toJson(),
      'closesAt': closesAt.toJson(),
      if (frozenAt != null) 'frozenAt': frozenAt?.toJson(),
      'closedAutomatically': closedAutomatically,
      'extendCount': extendCount,
      if (receiptTotalMinor != null) 'receiptTotalMinor': receiptTotalMinor,
      'currencyCode': currencyCode,
    };
  }

  static BasketInclude include() {
    return BasketInclude._();
  }

  static BasketIncludeList includeList({
    _is.WhereExpressionBuilder<BasketTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BasketTable>? orderBy,
    _is.OrderByListBuilder<BasketTable>? orderByList,
    BasketInclude? include,
  }) {
    return BasketIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Basket.t),
      orderByList: orderByList?.call(Basket.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BasketImpl extends Basket {
  _BasketImpl({
    int? id,
    required int householdId,
    required int shopperMemberId,
    int? storeId,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    required DateTime closesAt,
    DateTime? frozenAt,
    bool? closedAutomatically,
    int? extendCount,
    int? receiptTotalMinor,
    String? currencyCode,
  }) : super._(
         id: id,
         householdId: householdId,
         shopperMemberId: shopperMemberId,
         storeId: storeId,
         status: status,
         openedAt: openedAt,
         closesAt: closesAt,
         frozenAt: frozenAt,
         closedAutomatically: closedAutomatically,
         extendCount: extendCount,
         receiptTotalMinor: receiptTotalMinor,
         currencyCode: currencyCode,
       );

  /// Returns a shallow copy of this [Basket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Basket copyWith({
    Object? id = _Undefined,
    int? householdId,
    int? shopperMemberId,
    Object? storeId = _Undefined,
    _iumwz8so.BasketStatus? status,
    DateTime? openedAt,
    DateTime? closesAt,
    Object? frozenAt = _Undefined,
    bool? closedAutomatically,
    int? extendCount,
    Object? receiptTotalMinor = _Undefined,
    String? currencyCode,
  }) {
    return Basket(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      shopperMemberId: shopperMemberId ?? this.shopperMemberId,
      storeId: storeId is int? ? storeId : this.storeId,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      closesAt: closesAt ?? this.closesAt,
      frozenAt: frozenAt is DateTime? ? frozenAt : this.frozenAt,
      closedAutomatically: closedAutomatically ?? this.closedAutomatically,
      extendCount: extendCount ?? this.extendCount,
      receiptTotalMinor: receiptTotalMinor is int?
          ? receiptTotalMinor
          : this.receiptTotalMinor,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}

class BasketUpdateTable extends _is.UpdateTable<BasketTable> {
  BasketUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<int, int> shopperMemberId(int value) => _is.ColumnValue(
    table.shopperMemberId,
    value,
  );

  _is.ColumnValue<int, int> storeId(int? value) => _is.ColumnValue(
    table.storeId,
    value,
  );

  _is.ColumnValue<_iumwz8so.BasketStatus, _iumwz8so.BasketStatus> status(
    _iumwz8so.BasketStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> openedAt(DateTime value) =>
      _is.ColumnValue(
        table.openedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> closesAt(DateTime value) =>
      _is.ColumnValue(
        table.closesAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> frozenAt(DateTime? value) =>
      _is.ColumnValue(
        table.frozenAt,
        value,
      );

  _is.ColumnValue<bool, bool> closedAutomatically(bool value) =>
      _is.ColumnValue(
        table.closedAutomatically,
        value,
      );

  _is.ColumnValue<int, int> extendCount(int value) => _is.ColumnValue(
    table.extendCount,
    value,
  );

  _is.ColumnValue<int, int> receiptTotalMinor(int? value) => _is.ColumnValue(
    table.receiptTotalMinor,
    value,
  );

  _is.ColumnValue<String, String> currencyCode(String value) => _is.ColumnValue(
    table.currencyCode,
    value,
  );
}

class BasketTable extends _is.Table<int?> {
  BasketTable({super.tableRelation}) : super(tableName: 'basket') {
    updateTable = BasketUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    shopperMemberId = _is.ColumnInt(
      'shopperMemberId',
      this,
    );
    storeId = _is.ColumnInt(
      'storeId',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    openedAt = _is.ColumnDateTime(
      'openedAt',
      this,
      hasDefault: true,
    );
    closesAt = _is.ColumnDateTime(
      'closesAt',
      this,
    );
    frozenAt = _is.ColumnDateTime(
      'frozenAt',
      this,
    );
    closedAutomatically = _is.ColumnBool(
      'closedAutomatically',
      this,
      hasDefault: true,
    );
    extendCount = _is.ColumnInt(
      'extendCount',
      this,
      hasDefault: true,
    );
    receiptTotalMinor = _is.ColumnInt(
      'receiptTotalMinor',
      this,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
      hasDefault: true,
    );
  }

  late final BasketUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  /// The member doing the shopping. Only they may extend, freeze, mark items,
  /// enter prices, settle or cancel.
  late final _is.ColumnInt shopperMemberId;

  late final _is.ColumnInt storeId;

  late final _is.ColumnEnum<_iumwz8so.BasketStatus> status;

  late final _is.ColumnDateTime openedAt;

  /// The server owns this. The client only renders closesAt - serverNow.
  late final _is.ColumnDateTime closesAt;

  late final _is.ColumnDateTime frozenAt;

  /// True when the future call closed it rather than the shopper.
  late final _is.ColumnBool closedAutomatically;

  /// One +5 min extension per basket (ADR-009), so this is 0 or 1.
  late final _is.ColumnInt extendCount;

  /// What the till actually charged, in minor units. Null until entered.
  late final _is.ColumnInt receiptTotalMinor;

  /// The household's currency at the moment this basket closed. A settled
  /// basket keeps it, so changing the household setting never rewrites history.
  late final _is.ColumnString currencyCode;

  @override
  List<_is.Column> get columns => [
    id,
    householdId,
    shopperMemberId,
    storeId,
    status,
    openedAt,
    closesAt,
    frozenAt,
    closedAutomatically,
    extendCount,
    receiptTotalMinor,
    currencyCode,
  ];
}

class BasketInclude extends _is.IncludeObject {
  BasketInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Basket.t;
}

class BasketIncludeList extends _is.IncludeList {
  BasketIncludeList._({
    _is.WhereExpressionBuilder<BasketTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Basket.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Basket.t;
}

class BasketRepository {
  const BasketRepository._();

  /// Returns a list of [Basket]s matching the given query parameters.
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
  Future<List<Basket>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BasketTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BasketTable>? orderBy,
    _is.OrderByListBuilder<BasketTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Basket>(
      where: where?.call(Basket.t),
      orderBy: orderBy?.call(Basket.t),
      orderByList: orderByList?.call(Basket.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Basket] matching the given query parameters.
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
  Future<Basket?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BasketTable>? where,
    int? offset,
    _is.OrderByBuilder<BasketTable>? orderBy,
    _is.OrderByListBuilder<BasketTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Basket>(
      where: where?.call(Basket.t),
      orderBy: orderBy?.call(Basket.t),
      orderByList: orderByList?.call(Basket.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Basket] by its [id] or null if no such row exists.
  Future<Basket?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Basket>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Basket]s in the list and returns the inserted rows.
  ///
  /// The returned [Basket]s will have their `id` fields set.
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
  Future<List<Basket>> insert(
    _is.DatabaseSession session,
    List<Basket> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Basket>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Basket] and returns the inserted row.
  ///
  /// The returned [Basket] will have its `id` field set.
  Future<Basket> insertRow(
    _is.DatabaseSession session,
    Basket row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Basket>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Basket]s in the list and returns the resulting rows.
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
  /// The returned [Basket]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Basket>> upsert(
    _is.DatabaseSession session,
    List<Basket> rows, {
    required _is.ColumnSelections<BasketTable> conflictColumns,
    _is.ColumnSelections<BasketTable>? updateColumns,
    _is.WhereExpressionBuilder<BasketTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Basket>(
      rows,
      conflictColumns: conflictColumns(Basket.t),
      updateColumns: updateColumns?.call(Basket.t),
      updateWhere: updateWhere?.call(Basket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Basket] and returns the resulting row.
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
  /// The returned [Basket] will have its `id` field set.
  Future<Basket?> upsertRow(
    _is.DatabaseSession session,
    Basket row, {
    required _is.ColumnSelections<BasketTable> conflictColumns,
    _is.ColumnSelections<BasketTable>? updateColumns,
    _is.WhereExpressionBuilder<BasketTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Basket>(
      row,
      conflictColumns: conflictColumns(Basket.t),
      updateColumns: updateColumns?.call(Basket.t),
      updateWhere: updateWhere?.call(Basket.t),
      transaction: transaction,
    );
  }

  /// Updates all [Basket]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Basket>> update(
    _is.DatabaseSession session,
    List<Basket> rows, {
    _is.ColumnSelections<BasketTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Basket>(
      rows,
      columns: columns?.call(Basket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Basket]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Basket> updateRow(
    _is.DatabaseSession session,
    Basket row, {
    _is.ColumnSelections<BasketTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Basket>(
      row,
      columns: columns?.call(Basket.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Basket] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Basket?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<BasketUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Basket>(
      id,
      columnValues: columnValues(Basket.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Basket]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Basket>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BasketUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BasketTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BasketTable>? orderBy,
    _is.OrderByListBuilder<BasketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Basket>(
      columnValues: columnValues(Basket.t.updateTable),
      where: where(Basket.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Basket.t),
      orderByList: orderByList?.call(Basket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Basket]s in the list and returns the deleted rows.
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
  Future<List<Basket>> delete(
    _is.DatabaseSession session,
    List<Basket> rows, {
    _is.OrderByBuilder<BasketTable>? orderBy,
    _is.OrderByListBuilder<BasketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Basket>(
      rows,
      orderBy: orderBy?.call(Basket.t),
      orderByList: orderByList?.call(Basket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Basket].
  Future<Basket> deleteRow(
    _is.DatabaseSession session,
    Basket row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Basket>(
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
  Future<List<Basket>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BasketTable> where,
    _is.OrderByBuilder<BasketTable>? orderBy,
    _is.OrderByListBuilder<BasketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Basket>(
      where: where(Basket.t),
      orderBy: orderBy?.call(Basket.t),
      orderByList: orderByList?.call(Basket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BasketTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Basket>(
      where: where?.call(Basket.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Basket] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BasketTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Basket>(
      where: where(Basket.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
