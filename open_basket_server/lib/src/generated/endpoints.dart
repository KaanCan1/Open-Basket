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
import 'package:open_basket_server/src/generated/item_status.dart' as _i8v2xtko;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../endpoints/auth_endpoint.dart' as _iyggisn2;
import '../endpoints/basket_endpoint.dart' as _iq57g1s3;
import '../endpoints/basket_stream_endpoint.dart' as _i83pphaf;
import '../endpoints/device_endpoint.dart' as _ipl99gaq;
import '../endpoints/history_endpoint.dart' as _inbipg11;
import '../endpoints/household_endpoint.dart' as _izqmqbob;
import '../endpoints/settlement_endpoint.dart' as _ioestwe6;
import '../endpoints/stats_endpoint.dart' as _ii1l42ti;
import '../endpoints/store_endpoint.dart' as _iaxecmt0;
import '../greetings/greeting_endpoint.dart' as _il624ik7;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'auth': _iyggisn2.AuthEndpoint()
        ..initialize(
          server,
          'auth',
          null,
        ),
      'basket': _iq57g1s3.BasketEndpoint()
        ..initialize(
          server,
          'basket',
          null,
        ),
      'basketStream': _i83pphaf.BasketStreamEndpoint()
        ..initialize(
          server,
          'basketStream',
          null,
        ),
      'device': _ipl99gaq.DeviceEndpoint()
        ..initialize(
          server,
          'device',
          null,
        ),
      'history': _inbipg11.HistoryEndpoint()
        ..initialize(
          server,
          'history',
          null,
        ),
      'household': _izqmqbob.HouseholdEndpoint()
        ..initialize(
          server,
          'household',
          null,
        ),
      'settlement': _ioestwe6.SettlementEndpoint()
        ..initialize(
          server,
          'settlement',
          null,
        ),
      'stats': _ii1l42ti.StatsEndpoint()
        ..initialize(
          server,
          'stats',
          null,
        ),
      'store': _iaxecmt0.StoreEndpoint()
        ..initialize(
          server,
          'store',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['auth'] = _is.EndpointConnector(
      name: 'auth',
      endpoint: endpoints['auth']!,
      methodConnectors: {
        'requestSignInCode': _is.MethodConnector(
          name: 'requestSignInCode',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _iyggisn2.AuthEndpoint)
                  .requestSignInCode(
                    session,
                    params['email'],
                  ),
        ),
        'verifySignInCode': _is.MethodConnector(
          name: 'verifySignInCode',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _iyggisn2.AuthEndpoint)
                  .verifySignInCode(
                    session,
                    params['email'],
                    params['code'],
                  ),
        ),
      },
    );
    connectors['basket'] = _is.EndpointConnector(
      name: 'basket',
      endpoint: endpoints['basket']!,
      methodConnectors: {
        'getServerTime': _is.MethodConnector(
          name: 'getServerTime',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['basket'] as _iq57g1s3.BasketEndpoint)
                  .getServerTime(session),
        ),
        'open': _is.MethodConnector(
          name: 'open',
          params: {
            'storeId': _is.ParameterDescription(
              name: 'storeId',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'durationMinutes': _is.ParameterDescription(
              name: 'durationMinutes',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['basket'] as _iq57g1s3.BasketEndpoint).open(
                session,
                storeId: params['storeId'],
                durationMinutes: params['durationMinutes'],
              ),
        ),
        'extend': _is.MethodConnector(
          name: 'extend',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['basket'] as _iq57g1s3.BasketEndpoint).extend(
                    session,
                    params['basketId'],
                  ),
        ),
        'freeze': _is.MethodConnector(
          name: 'freeze',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['basket'] as _iq57g1s3.BasketEndpoint).freeze(
                    session,
                    params['basketId'],
                  ),
        ),
        'cancel': _is.MethodConnector(
          name: 'cancel',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['basket'] as _iq57g1s3.BasketEndpoint).cancel(
                    session,
                    params['basketId'],
                  ),
        ),
        'getActive': _is.MethodConnector(
          name: 'getActive',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['basket'] as _iq57g1s3.BasketEndpoint)
                  .getActive(session),
        ),
        'addItem': _is.MethodConnector(
          name: 'addItem',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'quantity': _is.ParameterDescription(
              name: 'quantity',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['basket'] as _iq57g1s3.BasketEndpoint).addItem(
                    session,
                    params['basketId'],
                    params['name'],
                    quantity: params['quantity'],
                    note: params['note'],
                  ),
        ),
        'updateItem': _is.MethodConnector(
          name: 'updateItem',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'quantity': _is.ParameterDescription(
              name: 'quantity',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['basket'] as _iq57g1s3.BasketEndpoint).updateItem(
                    session,
                    params['itemId'],
                    name: params['name'],
                    quantity: params['quantity'],
                    note: params['note'],
                  ),
        ),
        'removeItem': _is.MethodConnector(
          name: 'removeItem',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['basket'] as _iq57g1s3.BasketEndpoint).removeItem(
                    session,
                    params['itemId'],
                  ),
        ),
        'markItem': _is.MethodConnector(
          name: 'markItem',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'status': _is.ParameterDescription(
              name: 'status',
              type: _is.getType<_i8v2xtko.ItemStatus>(),
              nullable: false,
            ),
            'priceMinor': _is.ParameterDescription(
              name: 'priceMinor',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['basket'] as _iq57g1s3.BasketEndpoint).markItem(
                    session,
                    params['itemId'],
                    params['status'],
                    priceMinor: params['priceMinor'],
                  ),
        ),
        'setReceiptTotal': _is.MethodConnector(
          name: 'setReceiptTotal',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'receiptTotalMinor': _is.ParameterDescription(
              name: 'receiptTotalMinor',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['basket'] as _iq57g1s3.BasketEndpoint)
                  .setReceiptTotal(
                    session,
                    params['basketId'],
                    params['receiptTotalMinor'],
                  ),
        ),
      },
    );
    connectors['basketStream'] = _is.EndpointConnector(
      name: 'basketStream',
      endpoint: endpoints['basketStream']!,
      methodConnectors: {
        'watch': _is.MethodStreamConnector(
          name: 'watch',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['basketStream'] as _i83pphaf.BasketStreamEndpoint)
                  .watch(
                    session,
                    params['basketId'],
                  ),
        ),
      },
    );
    connectors['device'] = _is.EndpointConnector(
      name: 'device',
      endpoint: endpoints['device']!,
      methodConnectors: {
        'registerToken': _is.MethodConnector(
          name: 'registerToken',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _ipl99gaq.DeviceEndpoint)
                  .registerToken(
                    session,
                    params['token'],
                  ),
        ),
        'removeToken': _is.MethodConnector(
          name: 'removeToken',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['device'] as _ipl99gaq.DeviceEndpoint).removeToken(
                    session,
                    params['token'],
                  ),
        ),
      },
    );
    connectors['history'] = _is.EndpointConnector(
      name: 'history',
      endpoint: endpoints['history']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['history'] as _inbipg11.HistoryEndpoint).list(
                    session,
                    limit: params['limit'],
                  ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['history'] as _inbipg11.HistoryEndpoint).get(
                    session,
                    params['basketId'],
                  ),
        ),
      },
    );
    connectors['household'] = _is.EndpointConnector(
      name: 'household',
      endpoint: endpoints['household']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _izqmqbob.HouseholdEndpoint)
                  .create(
                    session,
                    params['name'],
                  ),
        ),
        'getMine': _is.MethodConnector(
          name: 'getMine',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _izqmqbob.HouseholdEndpoint)
                  .getMine(session),
        ),
        'joinWithCode': _is.MethodConnector(
          name: 'joinWithCode',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _izqmqbob.HouseholdEndpoint)
                  .joinWithCode(
                    session,
                    params['code'],
                  ),
        ),
        'rotateCode': _is.MethodConnector(
          name: 'rotateCode',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _izqmqbob.HouseholdEndpoint)
                  .rotateCode(session),
        ),
        'listMembers': _is.MethodConnector(
          name: 'listMembers',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _izqmqbob.HouseholdEndpoint)
                  .listMembers(session),
        ),
        'rename': _is.MethodConnector(
          name: 'rename',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _izqmqbob.HouseholdEndpoint)
                  .rename(
                    session,
                    params['name'],
                  ),
        ),
        'setCurrency': _is.MethodConnector(
          name: 'setCurrency',
          params: {
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _izqmqbob.HouseholdEndpoint)
                  .setCurrency(
                    session,
                    params['currencyCode'],
                  ),
        ),
        'setNotificationPreferences': _is.MethodConnector(
          name: 'setNotificationPreferences',
          params: {
            'basketOpened': _is.ParameterDescription(
              name: 'basketOpened',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'closingSoon': _is.ParameterDescription(
              name: 'closingSoon',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'settlementReady': _is.ParameterDescription(
              name: 'settlementReady',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _izqmqbob.HouseholdEndpoint)
                  .setNotificationPreferences(
                    session,
                    basketOpened: params['basketOpened'],
                    closingSoon: params['closingSoon'],
                    settlementReady: params['settlementReady'],
                  ),
        ),
        'leave': _is.MethodConnector(
          name: 'leave',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _izqmqbob.HouseholdEndpoint)
                  .leave(session),
        ),
      },
    );
    connectors['settlement'] = _is.EndpointConnector(
      name: 'settlement',
      endpoint: endpoints['settlement']!,
      methodConnectors: {
        'preview': _is.MethodConnector(
          name: 'preview',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['settlement'] as _ioestwe6.SettlementEndpoint)
                      .preview(
                        session,
                        params['basketId'],
                      ),
        ),
        'settle': _is.MethodConnector(
          name: 'settle',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['settlement'] as _ioestwe6.SettlementEndpoint)
                      .settle(
                        session,
                        params['basketId'],
                      ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'basketId': _is.ParameterDescription(
              name: 'basketId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['settlement'] as _ioestwe6.SettlementEndpoint).get(
                    session,
                    params['basketId'],
                  ),
        ),
      },
    );
    connectors['stats'] = _is.EndpointConnector(
      name: 'stats',
      endpoint: endpoints['stats']!,
      methodConnectors: {
        'report': _is.MethodConnector(
          name: 'report',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['stats'] as _ii1l42ti.StatsEndpoint).report(
                session,
              ),
        ),
      },
    );
    connectors['store'] = _is.EndpointConnector(
      name: 'store',
      endpoint: endpoints['store']!,
      methodConnectors: {
        'add': _is.MethodConnector(
          name: 'add',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'lat': _is.ParameterDescription(
              name: 'lat',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'lng': _is.ParameterDescription(
              name: 'lng',
              type: _is.getType<double?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['store'] as _iaxecmt0.StoreEndpoint).add(
                session,
                params['name'],
                lat: params['lat'],
                lng: params['lng'],
              ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['store'] as _iaxecmt0.StoreEndpoint).list(session),
        ),
        'remove': _is.MethodConnector(
          name: 'remove',
          params: {
            'storeId': _is.ParameterDescription(
              name: 'storeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['store'] as _iaxecmt0.StoreEndpoint).remove(
                session,
                params['storeId'],
              ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
