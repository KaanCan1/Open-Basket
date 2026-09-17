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
import 'item_status.dart' as _ibbyonnn;

/// Something a member asked for on a run.
abstract class BasketItem
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  BasketItem._({
    this.id,
    required this.basketId,
    required this.requesterMemberId,
    required this.name,
    int? quantity,
    this.note,
    _ibbyonnn.ItemStatus? status,
    this.priceMinor,
    DateTime? addedAt,
  }) : quantity = quantity ?? 1,
       status = status ?? _ibbyonnn.ItemStatus.requested,
       addedAt = addedAt ?? DateTime.now();

  factory BasketItem({
    int? id,
    required int basketId,
    required int requesterMemberId,
    required String name,
    int? quantity,
    String? note,
    _ibbyonnn.ItemStatus? status,
    int? priceMinor,
    DateTime? addedAt,
  }) = _BasketItemImpl;

  factory BasketItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return BasketItem(
      id: jsonSerialization['id'] as int?,
      basketId: jsonSerialization['basketId'] as int,
      requesterMemberId: jsonSerialization['requesterMemberId'] as int,
      name: jsonSerialization['name'] as String,
      quantity: jsonSerialization['quantity'] as int?,
      note: jsonSerialization['note'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _ibbyonnn.ItemStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      priceMinor: jsonSerialization['priceMinor'] as int?,
      addedAt: jsonSerialization['addedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['addedAt']),
    );
  }

  static final t = BasketItemTable();

  static const db = BasketItemRepository._();

  @override
  int? id;

  int basketId;

  /// Who asked for it. Drives the avatar on the row and who owes for it.
  int requesterMemberId;

  String name;

  int quantity;

  /// Free text: brand, size, "only if fresh".
  String? note;

  /// The shopper may set this while the basket is still open (ADR-005).
  _ibbyonnn.ItemStatus status;

  /// Minor units. Only set once the basket is frozen.
  int? priceMinor;

  DateTime addedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [BasketItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BasketItem copyWith({
    int? id,
    int? basketId,
    int? requesterMemberId,
    String? name,
    int? quantity,
    String? note,
    _ibbyonnn.ItemStatus? status,
    int? priceMinor,
    DateTime? addedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BasketItem',
      if (id != null) 'id': id,
      'basketId': basketId,
      'requesterMemberId': requesterMemberId,
      'name': name,
      'quantity': quantity,
      if (note != null) 'note': note,
      'status': status.toJson(),
      if (priceMinor != null) 'priceMinor': priceMinor,
      'addedAt': addedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BasketItem',
      if (id != null) 'id': id,
      'basketId': basketId,
      'requesterMemberId': requesterMemberId,
      'name': name,
      'quantity': quantity,
      if (note != null) 'note': note,
      'status': status.toJson(),
      if (priceMinor != null) 'priceMinor': priceMinor,
      'addedAt': addedAt.toJson(),
    };
  }

  static BasketItemInclude include() {
    return BasketItemInclude._();
  }

  static BasketItemIncludeList includeList({
    _is.WhereExpressionBuilder<BasketItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BasketItemTable>? orderBy,
    _is.OrderByListBuilder<BasketItemTable>? orderByList,
    BasketItemInclude? include,
  }) {
    return BasketItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BasketItem.t),
      orderByList: orderByList?.call(BasketItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BasketItemImpl extends BasketItem {
  _BasketItemImpl({
    int? id,
    required int basketId,
    required int requesterMemberId,
    required String name,
    int? quantity,
    String? note,
    _ibbyonnn.ItemStatus? status,
    int? priceMinor,
    DateTime? addedAt,
  }) : super._(
         id: id,
         basketId: basketId,
         requesterMemberId: requesterMemberId,
         name: name,
         quantity: quantity,
         note: note,
         status: status,
         priceMinor: priceMinor,
         addedAt: addedAt,
       );

  /// Returns a shallow copy of this [BasketItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BasketItem copyWith({
    Object? id = _Undefined,
    int? basketId,
    int? requesterMemberId,
    String? name,
    int? quantity,
    Object? note = _Undefined,
    _ibbyonnn.ItemStatus? status,
    Object? priceMinor = _Undefined,
    DateTime? addedAt,
  }) {
    return BasketItem(
      id: id is int? ? id : this.id,
      basketId: basketId ?? this.basketId,
      requesterMemberId: requesterMemberId ?? this.requesterMemberId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      note: note is String? ? note : this.note,
      status: status ?? this.status,
      priceMinor: priceMinor is int? ? priceMinor : this.priceMinor,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class BasketItemUpdateTable extends _is.UpdateTable<BasketItemTable> {
  BasketItemUpdateTable(super.table);

  _is.ColumnValue<int, int> basketId(int value) => _is.ColumnValue(
    table.basketId,
    value,
  );

  _is.ColumnValue<int, int> requesterMemberId(int value) => _is.ColumnValue(
    table.requesterMemberId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<int, int> quantity(int value) => _is.ColumnValue(
    table.quantity,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<_ibbyonnn.ItemStatus, _ibbyonnn.ItemStatus> status(
    _ibbyonnn.ItemStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> priceMinor(int? value) => _is.ColumnValue(
    table.priceMinor,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> addedAt(DateTime value) =>
      _is.ColumnValue(
        table.addedAt,
        value,
      );
}

class BasketItemTable extends _is.Table<int?> {
  BasketItemTable({super.tableRelation}) : super(tableName: 'basket_item') {
    updateTable = BasketItemUpdateTable(this);
    basketId = _is.ColumnInt(
      'basketId',
      this,
    );
    requesterMemberId = _is.ColumnInt(
      'requesterMemberId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    quantity = _is.ColumnInt(
      'quantity',
      this,
      hasDefault: true,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    priceMinor = _is.ColumnInt(
      'priceMinor',
      this,
    );
    addedAt = _is.ColumnDateTime(
      'addedAt',
      this,
      hasDefault: true,
    );
  }

  late final BasketItemUpdateTable updateTable;

  late final _is.ColumnInt basketId;

  /// Who asked for it. Drives the avatar on the row and who owes for it.
  late final _is.ColumnInt requesterMemberId;

  late final _is.ColumnString name;

  late final _is.ColumnInt quantity;

  /// Free text: brand, size, "only if fresh".
  late final _is.ColumnString note;

  /// The shopper may set this while the basket is still open (ADR-005).
  late final _is.ColumnEnum<_ibbyonnn.ItemStatus> status;

  /// Minor units. Only set once the basket is frozen.
  late final _is.ColumnInt priceMinor;

  late final _is.ColumnDateTime addedAt;

  @override
  List<_is.Column> get columns => [
    id,
    basketId,
    requesterMemberId,
    name,
    quantity,
    note,
    status,
    priceMinor,
    addedAt,
  ];
}

class BasketItemInclude extends _is.IncludeObject {
  BasketItemInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => BasketItem.t;
}

class BasketItemIncludeList extends _is.IncludeList {
  BasketItemIncludeList._({
    _is.WhereExpressionBuilder<BasketItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BasketItem.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => BasketItem.t;
}

class BasketItemRepository {
  const BasketItemRepository._();

  /// Returns a list of [BasketItem]s matching the given query parameters.
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
  Future<List<BasketItem>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BasketItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BasketItemTable>? orderBy,
    _is.OrderByListBuilder<BasketItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BasketItem>(
      where: where?.call(BasketItem.t),
      orderBy: orderBy?.call(BasketItem.t),
      orderByList: orderByList?.call(BasketItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [BasketItem] matching the given query parameters.
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
  Future<BasketItem?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BasketItemTable>? where,
    int? offset,
    _is.OrderByBuilder<BasketItemTable>? orderBy,
    _is.OrderByListBuilder<BasketItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BasketItem>(
      where: where?.call(BasketItem.t),
      orderBy: orderBy?.call(BasketItem.t),
      orderByList: orderByList?.call(BasketItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BasketItem] by its [id] or null if no such row exists.
  Future<BasketItem?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BasketItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BasketItem]s in the list and returns the inserted rows.
  ///
  /// The returned [BasketItem]s will have their `id` fields set.
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
  Future<List<BasketItem>> insert(
    _is.DatabaseSession session,
    List<BasketItem> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<BasketItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [BasketItem] and returns the inserted row.
  ///
  /// The returned [BasketItem] will have its `id` field set.
  Future<BasketItem> insertRow(
    _is.DatabaseSession session,
    BasketItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<BasketItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [BasketItem]s in the list and returns the resulting rows.
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
  /// The returned [BasketItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BasketItem>> upsert(
    _is.DatabaseSession session,
    List<BasketItem> rows, {
    required _is.ColumnSelections<BasketItemTable> conflictColumns,
    _is.ColumnSelections<BasketItemTable>? updateColumns,
    _is.WhereExpressionBuilder<BasketItemTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<BasketItem>(
      rows,
      conflictColumns: conflictColumns(BasketItem.t),
      updateColumns: updateColumns?.call(BasketItem.t),
      updateWhere: updateWhere?.call(BasketItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [BasketItem] and returns the resulting row.
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
  /// The returned [BasketItem] will have its `id` field set.
  Future<BasketItem?> upsertRow(
    _is.DatabaseSession session,
    BasketItem row, {
    required _is.ColumnSelections<BasketItemTable> conflictColumns,
    _is.ColumnSelections<BasketItemTable>? updateColumns,
    _is.WhereExpressionBuilder<BasketItemTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<BasketItem>(
      row,
      conflictColumns: conflictColumns(BasketItem.t),
      updateColumns: updateColumns?.call(BasketItem.t),
      updateWhere: updateWhere?.call(BasketItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [BasketItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BasketItem>> update(
    _is.DatabaseSession session,
    List<BasketItem> rows, {
    _is.ColumnSelections<BasketItemTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<BasketItem>(
      rows,
      columns: columns?.call(BasketItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [BasketItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BasketItem> updateRow(
    _is.DatabaseSession session,
    BasketItem row, {
    _is.ColumnSelections<BasketItemTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<BasketItem>(
      row,
      columns: columns?.call(BasketItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BasketItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BasketItem?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<BasketItemUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<BasketItem>(
      id,
      columnValues: columnValues(BasketItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BasketItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BasketItem>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BasketItemUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BasketItemTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BasketItemTable>? orderBy,
    _is.OrderByListBuilder<BasketItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<BasketItem>(
      columnValues: columnValues(BasketItem.t.updateTable),
      where: where(BasketItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BasketItem.t),
      orderByList: orderByList?.call(BasketItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [BasketItem]s in the list and returns the deleted rows.
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
  Future<List<BasketItem>> delete(
    _is.DatabaseSession session,
    List<BasketItem> rows, {
    _is.OrderByBuilder<BasketItemTable>? orderBy,
    _is.OrderByListBuilder<BasketItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<BasketItem>(
      rows,
      orderBy: orderBy?.call(BasketItem.t),
      orderByList: orderByList?.call(BasketItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [BasketItem].
  Future<BasketItem> deleteRow(
    _is.DatabaseSession session,
    BasketItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BasketItem>(
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
  Future<List<BasketItem>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BasketItemTable> where,
    _is.OrderByBuilder<BasketItemTable>? orderBy,
    _is.OrderByListBuilder<BasketItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<BasketItem>(
      where: where(BasketItem.t),
      orderBy: orderBy?.call(BasketItem.t),
      orderByList: orderByList?.call(BasketItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BasketItemTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<BasketItem>(
      where: where?.call(BasketItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BasketItem] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BasketItemTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BasketItem>(
      where: where(BasketItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
