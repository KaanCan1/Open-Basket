/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:open_basket_server/src/generated/household_member.dart'
    as _izwgjn1h;
import 'package:open_basket_server/src/generated/past_run.dart' as _iprw808a;
import 'package:open_basket_server/src/generated/settlement_line.dart'
    as _iw375zr9;
import 'package:open_basket_server/src/generated/store.dart' as _ie3cdud7;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'analytics_event.dart' as _iuylzfvu;
import 'basket.dart' as _incyaby3;
import 'basket_error.dart' as _ix8f32lp;
import 'basket_event.dart' as _imfibvkw;
import 'basket_event_type.dart' as _i1f6eto5;
import 'basket_item.dart' as _iqfe96ip;
import 'basket_status.dart' as _iumwz8so;
import 'device_token.dart' as _ilggw95u;
import 'future_calls_generated_models/close_basket_future_call_close_model.dart'
    as _itt3vjix;
import 'future_calls_generated_models/closing_soon_future_call_remind_model.dart'
    as _i9kzwx4t;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'household.dart' as _ijonbu5t;
import 'household_member.dart' as _iv10erpj;
import 'item_status.dart' as _ibbyonnn;
import 'join_attempt.dart' as _ira1fzaj;
import 'member_role.dart' as _insyygng;
import 'open_basket_exception.dart' as _ityrezdb;
import 'past_run.dart' as _ilcj9n2a;
import 'retired_household_code.dart' as _ijie3fvs;
import 'settlement_line.dart' as _i7gf6igf;
import 'sign_in_code.dart' as _iy6eg0ya;
import 'store.dart' as _ixrn3cz3;
export 'analytics_event.dart';
export 'basket.dart';
export 'basket_error.dart';
export 'basket_event.dart';
export 'basket_event_type.dart';
export 'basket_item.dart';
export 'basket_status.dart';
export 'device_token.dart';
export 'greetings/greeting.dart';
export 'household.dart';
export 'household_member.dart';
export 'item_status.dart';
export 'join_attempt.dart';
export 'member_role.dart';
export 'open_basket_exception.dart';
export 'past_run.dart';
export 'retired_household_code.dart';
export 'settlement_line.dart';
export 'sign_in_code.dart';
export 'store.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'analytics_event',
      dartName: 'AnalyticsEvent',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'basketId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'memberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'payload',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'analytics_type_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'type',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'basket',
      dartName: 'Basket',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'shopperMemberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'storeId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:BasketStatus',
          columnDefault: '\'open\'',
        ),
        _isp.ColumnDefinition(
          name: 'openedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'closesAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'frozenAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'closedAutomatically',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'extendCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'receiptTotalMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'TRY\'',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'basket_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'basket_fk_1',
          columns: ['shopperMemberId'],
          referenceTable: 'household_member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'basket_fk_2',
          columns: ['storeId'],
          referenceTable: 'store',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'basket_item',
      dartName: 'BasketItem',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'basketId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'requesterMemberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'quantity',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ItemStatus',
          columnDefault: '\'requested\'',
        ),
        _isp.ColumnDefinition(
          name: 'priceMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'addedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'basket_item_fk_0',
          columns: ['basketId'],
          referenceTable: 'basket',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'basket_item_fk_1',
          columns: ['requesterMemberId'],
          referenceTable: 'household_member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'device_token',
      dartName: 'DeviceToken',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'token',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'device_token__token__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'household',
      dartName: 'Household',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'currencyCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'TRY\'',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'household__code__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'code',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'household_member',
      dartName: 'HouseholdMember',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MemberRole',
          columnDefault: '\'member\'',
        ),
        _isp.ColumnDefinition(
          name: 'notifyBasketOpened',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'notifyClosingSoon',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'notifySettlementReady',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'leftAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'household_member_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'member_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'householdId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'join_attempt',
      dartName: 'JoinAttempt',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'attemptedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'join_attempt_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'attemptedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'retired_household_code',
      dartName: 'RetiredHouseholdCode',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'retiredAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'retired_household_code_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'retired_household_code_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'code',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'settlement_line',
      dartName: 'SettlementLine',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'basketId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'fromMemberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'toMemberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'amountMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'itemsMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'receiptGapMinor',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'settlement_line_fk_0',
          columns: ['basketId'],
          referenceTable: 'basket',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'settlement_line_fk_1',
          columns: ['fromMemberId'],
          referenceTable: 'household_member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'settlement_line_fk_2',
          columns: ['toMemberId'],
          referenceTable: 'household_member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'sign_in_code',
      dartName: 'SignInCode',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'email',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'codeHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'attemptsRemaining',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '3',
        ),
        _isp.ColumnDefinition(
          name: 'consumedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'sign_in_code_email_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'email',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'store',
      dartName: 'Store',
      schema: 'public',
      module: 'open_basket',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'lat',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'lng',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'store_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    ..._iacs.Protocol.targetTableDefinitions,
    ..._iais.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iuylzfvu.AnalyticsEvent) {
      return _iuylzfvu.AnalyticsEvent.fromJson(data) as T;
    }
    if (t == _incyaby3.Basket) {
      return _incyaby3.Basket.fromJson(data) as T;
    }
    if (t == _ix8f32lp.BasketError) {
      return _ix8f32lp.BasketError.fromJson(data) as T;
    }
    if (t == _imfibvkw.BasketEvent) {
      return _imfibvkw.BasketEvent.fromJson(data) as T;
    }
    if (t == _i1f6eto5.BasketEventType) {
      return _i1f6eto5.BasketEventType.fromJson(data) as T;
    }
    if (t == _iqfe96ip.BasketItem) {
      return _iqfe96ip.BasketItem.fromJson(data) as T;
    }
    if (t == _iumwz8so.BasketStatus) {
      return _iumwz8so.BasketStatus.fromJson(data) as T;
    }
    if (t == _ilggw95u.DeviceToken) {
      return _ilggw95u.DeviceToken.fromJson(data) as T;
    }
    if (t == _itt3vjix.CloseBasketFutureCallCloseModel) {
      return _itt3vjix.CloseBasketFutureCallCloseModel.fromJson(data) as T;
    }
    if (t == _i9kzwx4t.ClosingSoonFutureCallRemindModel) {
      return _i9kzwx4t.ClosingSoonFutureCallRemindModel.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _ijonbu5t.Household) {
      return _ijonbu5t.Household.fromJson(data) as T;
    }
    if (t == _iv10erpj.HouseholdMember) {
      return _iv10erpj.HouseholdMember.fromJson(data) as T;
    }
    if (t == _ibbyonnn.ItemStatus) {
      return _ibbyonnn.ItemStatus.fromJson(data) as T;
    }
    if (t == _ira1fzaj.JoinAttempt) {
      return _ira1fzaj.JoinAttempt.fromJson(data) as T;
    }
    if (t == _insyygng.MemberRole) {
      return _insyygng.MemberRole.fromJson(data) as T;
    }
    if (t == _ityrezdb.OpenBasketException) {
      return _ityrezdb.OpenBasketException.fromJson(data) as T;
    }
    if (t == _ilcj9n2a.PastRun) {
      return _ilcj9n2a.PastRun.fromJson(data) as T;
    }
    if (t == _ijie3fvs.RetiredHouseholdCode) {
      return _ijie3fvs.RetiredHouseholdCode.fromJson(data) as T;
    }
    if (t == _i7gf6igf.SettlementLine) {
      return _i7gf6igf.SettlementLine.fromJson(data) as T;
    }
    if (t == _iy6eg0ya.SignInCode) {
      return _iy6eg0ya.SignInCode.fromJson(data) as T;
    }
    if (t == _ixrn3cz3.Store) {
      return _ixrn3cz3.Store.fromJson(data) as T;
    }
    if (t == _is.getType<_iuylzfvu.AnalyticsEvent?>()) {
      return (data != null ? _iuylzfvu.AnalyticsEvent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_incyaby3.Basket?>()) {
      return (data != null ? _incyaby3.Basket.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ix8f32lp.BasketError?>()) {
      return (data != null ? _ix8f32lp.BasketError.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_imfibvkw.BasketEvent?>()) {
      return (data != null ? _imfibvkw.BasketEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i1f6eto5.BasketEventType?>()) {
      return (data != null ? _i1f6eto5.BasketEventType.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqfe96ip.BasketItem?>()) {
      return (data != null ? _iqfe96ip.BasketItem.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iumwz8so.BasketStatus?>()) {
      return (data != null ? _iumwz8so.BasketStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ilggw95u.DeviceToken?>()) {
      return (data != null ? _ilggw95u.DeviceToken.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_itt3vjix.CloseBasketFutureCallCloseModel?>()) {
      return (data != null
              ? _itt3vjix.CloseBasketFutureCallCloseModel.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9kzwx4t.ClosingSoonFutureCallRemindModel?>()) {
      return (data != null
              ? _i9kzwx4t.ClosingSoonFutureCallRemindModel.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijonbu5t.Household?>()) {
      return (data != null ? _ijonbu5t.Household.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iv10erpj.HouseholdMember?>()) {
      return (data != null ? _iv10erpj.HouseholdMember.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ibbyonnn.ItemStatus?>()) {
      return (data != null ? _ibbyonnn.ItemStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ira1fzaj.JoinAttempt?>()) {
      return (data != null ? _ira1fzaj.JoinAttempt.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_insyygng.MemberRole?>()) {
      return (data != null ? _insyygng.MemberRole.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ityrezdb.OpenBasketException?>()) {
      return (data != null
              ? _ityrezdb.OpenBasketException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ilcj9n2a.PastRun?>()) {
      return (data != null ? _ilcj9n2a.PastRun.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijie3fvs.RetiredHouseholdCode?>()) {
      return (data != null
              ? _ijie3fvs.RetiredHouseholdCode.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i7gf6igf.SettlementLine?>()) {
      return (data != null ? _i7gf6igf.SettlementLine.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iy6eg0ya.SignInCode?>()) {
      return (data != null ? _iy6eg0ya.SignInCode.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ixrn3cz3.Store?>()) {
      return (data != null ? _ixrn3cz3.Store.fromJson(data) : null) as T;
    }
    if (t == List<_iqfe96ip.BasketItem>) {
      return (data as List)
              .map((e) => deserialize<_iqfe96ip.BasketItem>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_iqfe96ip.BasketItem>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_iqfe96ip.BasketItem>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == Map<int, int>) {
      return Map.fromEntries(
            (data as List).map(
              (e) =>
                  MapEntry(deserialize<int>(e['k']), deserialize<int>(e['v'])),
            ),
          )
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_iprw808a.PastRun>) {
      return (data as List)
              .map((e) => deserialize<_iprw808a.PastRun>(e))
              .toList()
          as T;
    }
    if (t == List<_izwgjn1h.HouseholdMember>) {
      return (data as List)
              .map((e) => deserialize<_izwgjn1h.HouseholdMember>(e))
              .toList()
          as T;
    }
    if (t == List<_iw375zr9.SettlementLine>) {
      return (data as List)
              .map((e) => deserialize<_iw375zr9.SettlementLine>(e))
              .toList()
          as T;
    }
    if (t == List<_ie3cdud7.Store>) {
      return (data as List).map((e) => deserialize<_ie3cdud7.Store>(e)).toList()
          as T;
    }
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iuylzfvu.AnalyticsEvent => 'AnalyticsEvent',
      _incyaby3.Basket => 'Basket',
      _ix8f32lp.BasketError => 'BasketError',
      _imfibvkw.BasketEvent => 'BasketEvent',
      _i1f6eto5.BasketEventType => 'BasketEventType',
      _iqfe96ip.BasketItem => 'BasketItem',
      _iumwz8so.BasketStatus => 'BasketStatus',
      _ilggw95u.DeviceToken => 'DeviceToken',
      _itt3vjix.CloseBasketFutureCallCloseModel =>
        'CloseBasketFutureCallCloseModel',
      _i9kzwx4t.ClosingSoonFutureCallRemindModel =>
        'ClosingSoonFutureCallRemindModel',
      _izw8z7ou.Greeting => 'Greeting',
      _ijonbu5t.Household => 'Household',
      _iv10erpj.HouseholdMember => 'HouseholdMember',
      _ibbyonnn.ItemStatus => 'ItemStatus',
      _ira1fzaj.JoinAttempt => 'JoinAttempt',
      _insyygng.MemberRole => 'MemberRole',
      _ityrezdb.OpenBasketException => 'OpenBasketException',
      _ilcj9n2a.PastRun => 'PastRun',
      _ijie3fvs.RetiredHouseholdCode => 'RetiredHouseholdCode',
      _i7gf6igf.SettlementLine => 'SettlementLine',
      _iy6eg0ya.SignInCode => 'SignInCode',
      _ixrn3cz3.Store => 'Store',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('open_basket.', '');
    }

    switch (data) {
      case _iuylzfvu.AnalyticsEvent():
        return 'AnalyticsEvent';
      case _incyaby3.Basket():
        return 'Basket';
      case _ix8f32lp.BasketError():
        return 'BasketError';
      case _imfibvkw.BasketEvent():
        return 'BasketEvent';
      case _i1f6eto5.BasketEventType():
        return 'BasketEventType';
      case _iqfe96ip.BasketItem():
        return 'BasketItem';
      case _iumwz8so.BasketStatus():
        return 'BasketStatus';
      case _ilggw95u.DeviceToken():
        return 'DeviceToken';
      case _itt3vjix.CloseBasketFutureCallCloseModel():
        return 'CloseBasketFutureCallCloseModel';
      case _i9kzwx4t.ClosingSoonFutureCallRemindModel():
        return 'ClosingSoonFutureCallRemindModel';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _ijonbu5t.Household():
        return 'Household';
      case _iv10erpj.HouseholdMember():
        return 'HouseholdMember';
      case _ibbyonnn.ItemStatus():
        return 'ItemStatus';
      case _ira1fzaj.JoinAttempt():
        return 'JoinAttempt';
      case _insyygng.MemberRole():
        return 'MemberRole';
      case _ityrezdb.OpenBasketException():
        return 'OpenBasketException';
      case _ilcj9n2a.PastRun():
        return 'PastRun';
      case _ijie3fvs.RetiredHouseholdCode():
        return 'RetiredHouseholdCode';
      case _i7gf6igf.SettlementLine():
        return 'SettlementLine';
      case _iy6eg0ya.SignInCode():
        return 'SignInCode';
      case _ixrn3cz3.Store():
        return 'Store';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AnalyticsEvent') {
      return deserialize<_iuylzfvu.AnalyticsEvent>(data['data']);
    }
    if (dataClassName == 'Basket') {
      return deserialize<_incyaby3.Basket>(data['data']);
    }
    if (dataClassName == 'BasketError') {
      return deserialize<_ix8f32lp.BasketError>(data['data']);
    }
    if (dataClassName == 'BasketEvent') {
      return deserialize<_imfibvkw.BasketEvent>(data['data']);
    }
    if (dataClassName == 'BasketEventType') {
      return deserialize<_i1f6eto5.BasketEventType>(data['data']);
    }
    if (dataClassName == 'BasketItem') {
      return deserialize<_iqfe96ip.BasketItem>(data['data']);
    }
    if (dataClassName == 'BasketStatus') {
      return deserialize<_iumwz8so.BasketStatus>(data['data']);
    }
    if (dataClassName == 'DeviceToken') {
      return deserialize<_ilggw95u.DeviceToken>(data['data']);
    }
    if (dataClassName == 'CloseBasketFutureCallCloseModel') {
      return deserialize<_itt3vjix.CloseBasketFutureCallCloseModel>(
        data['data'],
      );
    }
    if (dataClassName == 'ClosingSoonFutureCallRemindModel') {
      return deserialize<_i9kzwx4t.ClosingSoonFutureCallRemindModel>(
        data['data'],
      );
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'Household') {
      return deserialize<_ijonbu5t.Household>(data['data']);
    }
    if (dataClassName == 'HouseholdMember') {
      return deserialize<_iv10erpj.HouseholdMember>(data['data']);
    }
    if (dataClassName == 'ItemStatus') {
      return deserialize<_ibbyonnn.ItemStatus>(data['data']);
    }
    if (dataClassName == 'JoinAttempt') {
      return deserialize<_ira1fzaj.JoinAttempt>(data['data']);
    }
    if (dataClassName == 'MemberRole') {
      return deserialize<_insyygng.MemberRole>(data['data']);
    }
    if (dataClassName == 'OpenBasketException') {
      return deserialize<_ityrezdb.OpenBasketException>(data['data']);
    }
    if (dataClassName == 'PastRun') {
      return deserialize<_ilcj9n2a.PastRun>(data['data']);
    }
    if (dataClassName == 'RetiredHouseholdCode') {
      return deserialize<_ijie3fvs.RetiredHouseholdCode>(data['data']);
    }
    if (dataClassName == 'SettlementLine') {
      return deserialize<_i7gf6igf.SettlementLine>(data['data']);
    }
    if (dataClassName == 'SignInCode') {
      return deserialize<_iy6eg0ya.SignInCode>(data['data']);
    }
    if (dataClassName == 'Store') {
      return deserialize<_ixrn3cz3.Store>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacs.Protocol().registerHostProtocol('open_basket', this);
    _iais.Protocol().registerHostProtocol('open_basket', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iuylzfvu.AnalyticsEvent:
        return _iuylzfvu.AnalyticsEvent.t;
      case _incyaby3.Basket:
        return _incyaby3.Basket.t;
      case _iqfe96ip.BasketItem:
        return _iqfe96ip.BasketItem.t;
      case _ilggw95u.DeviceToken:
        return _ilggw95u.DeviceToken.t;
      case _ijonbu5t.Household:
        return _ijonbu5t.Household.t;
      case _iv10erpj.HouseholdMember:
        return _iv10erpj.HouseholdMember.t;
      case _ira1fzaj.JoinAttempt:
        return _ira1fzaj.JoinAttempt.t;
      case _ijie3fvs.RetiredHouseholdCode:
        return _ijie3fvs.RetiredHouseholdCode.t;
      case _i7gf6igf.SettlementLine:
        return _i7gf6igf.SettlementLine.t;
      case _iy6eg0ya.SignInCode:
        return _iy6eg0ya.SignInCode.t;
      case _ixrn3cz3.Store:
        return _ixrn3cz3.Store.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'open_basket';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
