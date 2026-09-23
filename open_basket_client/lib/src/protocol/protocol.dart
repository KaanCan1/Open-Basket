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
import 'package:open_basket_client/src/protocol/household_member.dart'
    as _i5id5rp2;
import 'package:open_basket_client/src/protocol/past_run.dart' as _igqoy608;
import 'package:open_basket_client/src/protocol/settlement_line.dart'
    as _i27lt87a;
import 'package:open_basket_client/src/protocol/store.dart' as _icg68kho;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'analytics_event.dart' as _iuylzfvu;
import 'basket.dart' as _incyaby3;
import 'basket_error.dart' as _ix8f32lp;
import 'basket_event.dart' as _imfibvkw;
import 'basket_event_type.dart' as _i1f6eto5;
import 'basket_item.dart' as _iqfe96ip;
import 'basket_status.dart' as _iumwz8so;
import 'device_token.dart' as _ilggw95u;
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
export 'store.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

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
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _ixrn3cz3.Store) {
      return _ixrn3cz3.Store.fromJson(data) as T;
    }
    if (t == _isc.getType<_iuylzfvu.AnalyticsEvent?>()) {
      return (data != null ? _iuylzfvu.AnalyticsEvent.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_incyaby3.Basket?>()) {
      return (data != null ? _incyaby3.Basket.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ix8f32lp.BasketError?>()) {
      return (data != null ? _ix8f32lp.BasketError.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_imfibvkw.BasketEvent?>()) {
      return (data != null ? _imfibvkw.BasketEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i1f6eto5.BasketEventType?>()) {
      return (data != null ? _i1f6eto5.BasketEventType.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iqfe96ip.BasketItem?>()) {
      return (data != null ? _iqfe96ip.BasketItem.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iumwz8so.BasketStatus?>()) {
      return (data != null ? _iumwz8so.BasketStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ilggw95u.DeviceToken?>()) {
      return (data != null ? _ilggw95u.DeviceToken.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijonbu5t.Household?>()) {
      return (data != null ? _ijonbu5t.Household.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iv10erpj.HouseholdMember?>()) {
      return (data != null ? _iv10erpj.HouseholdMember.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ibbyonnn.ItemStatus?>()) {
      return (data != null ? _ibbyonnn.ItemStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ira1fzaj.JoinAttempt?>()) {
      return (data != null ? _ira1fzaj.JoinAttempt.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_insyygng.MemberRole?>()) {
      return (data != null ? _insyygng.MemberRole.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ityrezdb.OpenBasketException?>()) {
      return (data != null
              ? _ityrezdb.OpenBasketException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ilcj9n2a.PastRun?>()) {
      return (data != null ? _ilcj9n2a.PastRun.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijie3fvs.RetiredHouseholdCode?>()) {
      return (data != null
              ? _ijie3fvs.RetiredHouseholdCode.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i7gf6igf.SettlementLine?>()) {
      return (data != null ? _i7gf6igf.SettlementLine.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixrn3cz3.Store?>()) {
      return (data != null ? _ixrn3cz3.Store.fromJson(data) : null) as T;
    }
    if (t == List<_iqfe96ip.BasketItem>) {
      return (data as List)
              .map((e) => deserialize<_iqfe96ip.BasketItem>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_iqfe96ip.BasketItem>?>()) {
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
    if (t == List<_igqoy608.PastRun>) {
      return (data as List)
              .map((e) => deserialize<_igqoy608.PastRun>(e))
              .toList()
          as T;
    }
    if (t == List<_i5id5rp2.HouseholdMember>) {
      return (data as List)
              .map((e) => deserialize<_i5id5rp2.HouseholdMember>(e))
              .toList()
          as T;
    }
    if (t == List<_i27lt87a.SettlementLine>) {
      return (data as List)
              .map((e) => deserialize<_i27lt87a.SettlementLine>(e))
              .toList()
          as T;
    }
    if (t == List<_icg68kho.Store>) {
      return (data as List).map((e) => deserialize<_icg68kho.Store>(e)).toList()
          as T;
    }
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
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
      case _ixrn3cz3.Store():
        return 'Store';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
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
    if (dataClassName == 'Store') {
      return deserialize<_ixrn3cz3.Store>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacc.Protocol().registerHostProtocol('open_basket', this);
    _iaic.Protocol().registerHostProtocol('open_basket', this);
  }

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
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
