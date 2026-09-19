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
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:open_basket_client/src/protocol/basket.dart' as _ifmsley9;
import 'package:open_basket_client/src/protocol/basket_event.dart' as _ivynb499;
import 'package:open_basket_client/src/protocol/basket_item.dart' as _iuuhmcji;
import 'package:open_basket_client/src/protocol/device_token.dart' as _i06kh2mj;
import 'package:open_basket_client/src/protocol/greetings/greeting.dart'
    as _i7bh5n7n;
import 'package:open_basket_client/src/protocol/household.dart' as _iig1c7mf;
import 'package:open_basket_client/src/protocol/household_member.dart'
    as _i5id5rp2;
import 'package:open_basket_client/src/protocol/item_status.dart' as _i3z6uioy;
import 'package:open_basket_client/src/protocol/settlement_line.dart'
    as _i27lt87a;
import 'package:open_basket_client/src/protocol/store.dart' as _icg68kho;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// The basket lifecycle: open, extend, freeze, cancel, and everything that
/// happens to the items inside it.
///
/// `open -> frozen -> settled`, plus `open -> cancelled`.
/// {@category Endpoint}
class EndpointBasket extends _isc.EndpointRef {
  EndpointBasket(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'basket';

  /// The server's clock, fetched on connect so the countdown can correct for
  /// drift. The client never trusts the device clock for `closesAt`.
  _ida.Future<DateTime> getServerTime() => caller.callServerEndpoint<DateTime>(
    'basket',
    'getServerTime',
    {},
  );

  /// Opens a run. `closesAt` is `now + durationMinutes`, computed here.
  ///
  /// Throws `householdAlreadyHasOpenBasket` when one is already running — the
  /// client turns that into the "someone else already has a basket open"
  /// screen rather than an error. Two simultaneous calls must not both
  /// succeed: the partial unique index noted in `basket.spy.yaml` is the real
  /// guarantee, the transaction alone is not.
  ///
  /// Schedules the close and the "2 minutes left" future calls.
  _ida.Future<_ifmsley9.Basket> open({
    int? storeId,
    required int durationMinutes,
  }) => caller.callServerEndpoint<_ifmsley9.Basket>(
    'basket',
    'open',
    {
      'storeId': storeId,
      'durationMinutes': durationMinutes,
    },
  );

  /// Adds five minutes, once per basket, shopper only (ADR-009). Throws
  /// `extensionAlreadyUsed` on the second attempt. Reschedules the future
  /// calls; the superseded one becomes a no-op when it fires.
  _ida.Future<_ifmsley9.Basket> extend(int basketId) =>
      caller.callServerEndpoint<_ifmsley9.Basket>(
        'basket',
        'extend',
        {'basketId': basketId},
      );

  /// "At checkout" — no more items. Shopper only.
  _ida.Future<_ifmsley9.Basket> freeze(int basketId) =>
      caller.callServerEndpoint<_ifmsley9.Basket>(
        'basket',
        'freeze',
        {'basketId': basketId},
      );

  /// Shopper only. Nothing is priced and nobody owes anybody; the run shows up
  /// in history as cancelled.
  _ida.Future<_ifmsley9.Basket> cancel(int basketId) =>
      caller.callServerEndpoint<_ifmsley9.Basket>(
        'basket',
        'cancel',
        {'basketId': basketId},
      );

  /// The household's open or frozen basket, or null. This is also what a
  /// client calls on cold start to discover that a basket closed while it was
  /// away.
  _ida.Future<_ifmsley9.Basket?> getActive() =>
      caller.callServerEndpoint<_ifmsley9.Basket?>(
        'basket',
        'getActive',
        {},
      );

  /// Any member, while the basket is `open`.
  _ida.Future<_iuuhmcji.BasketItem> addItem(
    int basketId,
    String name, {
    required int quantity,
    String? note,
  }) => caller.callServerEndpoint<_iuuhmcji.BasketItem>(
    'basket',
    'addItem',
    {
      'basketId': basketId,
      'name': name,
      'quantity': quantity,
      'note': note,
    },
  );

  /// Only the member who asked for the item, and only while `open`.
  _ida.Future<_iuuhmcji.BasketItem> updateItem(
    int itemId, {
    String? name,
    int? quantity,
    String? note,
  }) => caller.callServerEndpoint<_iuuhmcji.BasketItem>(
    'basket',
    'updateItem',
    {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'note': note,
    },
  );

  /// Only the member who asked for it, and only while `open`.
  _ida.Future<void> removeItem(int itemId) => caller.callServerEndpoint<void>(
    'basket',
    'removeItem',
    {'itemId': itemId},
  );

  /// Ticks an item off. Shopper only, allowed in **both** `open` and `frozen`
  /// (ADR-005) — the shopper marks things as they walk the aisles. `priceMinor`
  /// is only accepted once the basket is `frozen`.
  ///
  /// Publishes an `itemUpdated` event, so members watching see it live.
  _ida.Future<_iuuhmcji.BasketItem> markItem(
    int itemId,
    _i3z6uioy.ItemStatus status, {
    int? priceMinor,
  }) => caller.callServerEndpoint<_iuuhmcji.BasketItem>(
    'basket',
    'markItem',
    {
      'itemId': itemId,
      'status': status,
      'priceMinor': priceMinor,
    },
  );

  /// The till total, in minor units. Any difference from the item sum is split
  /// across every member at settlement (ADR-007); this only records it.
  _ida.Future<_ifmsley9.Basket> setReceiptTotal(
    int basketId,
    int receiptTotalMinor,
  ) => caller.callServerEndpoint<_ifmsley9.Basket>(
    'basket',
    'setReceiptTotal',
    {
      'basketId': basketId,
      'receiptTotalMinor': receiptTotalMinor,
    },
  );
}

/// The live basket.
/// {@category Endpoint}
class EndpointBasketStream extends _isc.EndpointRef {
  EndpointBasketStream(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'basketStream';

  /// Watches one basket.
  ///
  /// The first event is always a `snapshot` carrying the basket and all of its
  /// items, so a client that dropped its connection resyncs from the stream
  /// itself and never needs a second call. Every event carries `serverTime`.
  ///
  /// Throws `notAMember` before yielding anything.
  _ida.Stream<_ivynb499.BasketEvent> watch(int basketId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ivynb499.BasketEvent>,
        _ivynb499.BasketEvent
      >(
        'basketStream',
        'watch',
        {'basketId': basketId},
        {},
      );
}

/// FCM registration tokens. Which of the three notification types actually go
/// out is a per-member preference on `HouseholdMember` (ADR-010), checked on
/// the server before sending.
/// {@category Endpoint}
class EndpointDevice extends _isc.EndpointRef {
  EndpointDevice(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'device';

  /// Idempotent: re-registering an existing token refreshes it.
  _ida.Future<_i06kh2mj.DeviceToken> registerToken(String token) =>
      caller.callServerEndpoint<_i06kh2mj.DeviceToken>(
        'device',
        'registerToken',
        {'token': token},
      );

  /// Called on sign-out, so a shared phone stops receiving another member's
  /// notifications.
  _ida.Future<void> removeToken(String token) =>
      caller.callServerEndpoint<void>(
        'device',
        'removeToken',
        {'token': token},
      );
}

/// Past runs.
/// {@category Endpoint}
class EndpointHistory extends _isc.EndpointRef {
  EndpointHistory(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'history';

  /// Newest first. Settled and cancelled runs both appear.
  _ida.Future<List<_ifmsley9.Basket>> list({required int limit}) =>
      caller.callServerEndpoint<List<_ifmsley9.Basket>>(
        'history',
        'list',
        {'limit': limit},
      );

  /// One past run in full: its items with who asked and what they cost, and
  /// its settlement lines if it has any. A cancelled run has neither prices
  /// nor lines. Read-only.
  _ida.Future<_ivynb499.BasketEvent> get(int basketId) =>
      caller.callServerEndpoint<_ivynb499.BasketEvent>(
        'history',
        'get',
        {'basketId': basketId},
      );
}

/// Creating, joining and administering a household.
/// {@category Endpoint}
class EndpointHousehold extends _isc.EndpointRef {
  EndpointHousehold(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'household';

  /// Creates a household with a fresh six-character code and makes the caller
  /// its owner. Throws `alreadyInAHousehold` if the caller is already in one.
  _ida.Future<_iig1c7mf.Household> create(String name) =>
      caller.callServerEndpoint<_iig1c7mf.Household>(
        'household',
        'create',
        {'name': name},
      );

  /// The caller's household, or null if they have not joined one yet. The
  /// router sends a null here to "Create or join".
  _ida.Future<_iig1c7mf.Household?> getMine() =>
      caller.callServerEndpoint<_iig1c7mf.Household?>(
        'household',
        'getMine',
        {},
      );

  /// Joins by code. Throws `unknownHouseholdCode` for both a typo and a code
  /// that has been rotated away — the client words those differently but the
  /// server must not confirm that a code once existed.
  _ida.Future<_iig1c7mf.Household> joinWithCode(String code) =>
      caller.callServerEndpoint<_iig1c7mf.Household>(
        'household',
        'joinWithCode',
        {'code': code},
      );

  /// Issues a new code and kills the old one immediately (ADR-006). Owner only.
  /// Existing members are unaffected and nothing in history changes.
  _ida.Future<_iig1c7mf.Household> rotateCode() =>
      caller.callServerEndpoint<_iig1c7mf.Household>(
        'household',
        'rotateCode',
        {},
      );

  _ida.Future<List<_i5id5rp2.HouseholdMember>> listMembers() =>
      caller.callServerEndpoint<List<_i5id5rp2.HouseholdMember>>(
        'household',
        'listMembers',
        {},
      );

  /// Owner only.
  _ida.Future<_iig1c7mf.Household> rename(String name) =>
      caller.callServerEndpoint<_iig1c7mf.Household>(
        'household',
        'rename',
        {'name': name},
      );

  /// Owner only. ISO 4217. Never converts anything: settled baskets keep the
  /// code they closed with (ADR-008).
  _ida.Future<_iig1c7mf.Household> setCurrency(String currencyCode) =>
      caller.callServerEndpoint<_iig1c7mf.Household>(
        'household',
        'setCurrency',
        {'currencyCode': currencyCode},
      );

  /// The caller's own three notification switches (ADR-010).
  _ida.Future<_i5id5rp2.HouseholdMember> setNotificationPreferences({
    required bool basketOpened,
    required bool closingSoon,
    required bool settlementReady,
  }) => caller.callServerEndpoint<_i5id5rp2.HouseholdMember>(
    'household',
    'setNotificationPreferences',
    {
      'basketOpened': basketOpened,
      'closingSoon': closingSoon,
      'settlementReady': settlementReady,
    },
  );

  /// Leaves the household. The caller loses access to its history.
  _ida.Future<void> leave() => caller.callServerEndpoint<void>(
    'household',
    'leave',
    {},
  );
}

/// Working out who owes whom. The arithmetic lives in
/// `services/settlement_service.dart` as a pure function so it can be tested
/// without a database.
/// {@category Endpoint}
class EndpointSettlement extends _isc.EndpointRef {
  EndpointSettlement(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'settlement';

  /// What settling would produce, without writing anything. Lets the checkout
  /// screen show the split before the shopper commits.
  _ida.Future<List<_i27lt87a.SettlementLine>> preview(int basketId) =>
      caller.callServerEndpoint<List<_i27lt87a.SettlementLine>>(
        'settlement',
        'preview',
        {'basketId': basketId},
      );

  /// Writes the lines and moves the basket to `settled`. Shopper only.
  ///
  /// Each member owes their own picked items plus an even share of the gap
  /// between the receipt total and the item sum — every member, including one
  /// who asked for nothing. The remainder goes to the shopper so the lines
  /// always sum to exactly what they paid (ADR-007).
  ///
  /// Throws `basketNotFrozen` too early and `basketAlreadySettled` twice: the
  /// result is immutable.
  _ida.Future<List<_i27lt87a.SettlementLine>> settle(int basketId) =>
      caller.callServerEndpoint<List<_i27lt87a.SettlementLine>>(
        'settlement',
        'settle',
        {'basketId': basketId},
      );

  _ida.Future<List<_i27lt87a.SettlementLine>> get(int basketId) =>
      caller.callServerEndpoint<List<_i27lt87a.SettlementLine>>(
        'settlement',
        'get',
        {'basketId': basketId},
      );
}

/// Passwordless sign-in: the user types an email address, we email a six-digit
/// code, they type it back (ADR-004).
///
/// The bundled email identity provider is password-based — its only code flows
/// are registration verification and password reset — so this flow is ours.
/// The policy lives in [SignInService]; this is the wire.
/// Named `SignInEndpoint`, not `AuthEndpoint`, so the client reaches it at
/// `client.signIn`. `client.auth` belongs to the Serverpod auth module — the
/// session manager, `isAuthenticated`, sign-out — and an endpoint called
/// `auth` silently shadows all of it.
/// {@category Endpoint}
class EndpointSignIn extends _isc.EndpointRef {
  EndpointSignIn(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'signIn';

  /// Issues a code and emails it. Invalidates any code still outstanding for
  /// this address.
  ///
  /// Returns the same result whether or not the address already has an
  /// account: the response must not reveal who has signed up. Inside the
  /// resend cooldown it does nothing and the code already in flight stays
  /// valid.
  _ida.Future<void> requestSignInCode(String email) =>
      caller.callServerEndpoint<void>(
        'signIn',
        'requestSignInCode',
        {'email': email},
      );

  /// Exchanges a code for a session, creating the account on first use.
  ///
  /// Throws `OpenBasketException` with `invalidSignInCode`, `signInCodeExpired`
  /// or `tooManySignInAttempts` so the client can tell the three apart — the
  /// screens word them differently.
  _ida.Future<_iacc.AuthSuccess> verifySignInCode(
    String email,
    String code,
  ) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'signIn',
    'verifySignInCode',
    {
      'email': email,
      'code': code,
    },
  );
}

/// Numbers for the Day 26 report, read out of `analytics_event`. Everything
/// here depends on events having been written since Day 2 — a metric added
/// later is data already lost.
/// {@category Endpoint}
class EndpointStats extends _isc.EndpointRef {
  EndpointStats(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'stats';

  /// Baskets opened, items per basket, how runs ended (auto-closed, frozen by
  /// hand, cancelled, settled), average chosen duration, extension rate,
  /// median time from open to first item, and the share of members who added
  /// at least one item — the headline metric, "shared attention".
  ///
  /// Returns JSON so the report script can grow new metrics without a model
  /// change.
  _ida.Future<String> report() => caller.callServerEndpoint<String>(
    'stats',
    'report',
    {},
  );
}

/// Shops the household uses. Only a store's own fixed location is ever stored;
/// nobody's live position reaches the server (ADR-002).
/// {@category Endpoint}
class EndpointStore extends _isc.EndpointRef {
  EndpointStore(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'store';

  /// `lat`/`lng` are null when the member skipped the location step, in which
  /// case the client stops suggesting a duration and defaults to 10 minutes.
  _ida.Future<_icg68kho.Store> add(
    String name, {
    double? lat,
    double? lng,
  }) => caller.callServerEndpoint<_icg68kho.Store>(
    'store',
    'add',
    {
      'name': name,
      'lat': lat,
      'lng': lng,
    },
  );

  _ida.Future<List<_icg68kho.Store>> list() =>
      caller.callServerEndpoint<List<_icg68kho.Store>>(
        'store',
        'list',
        {},
      );

  /// Baskets that already used this store keep working: the relation is
  /// `onDelete=SetNull`, so history does not lose its rows.
  _ida.Future<void> remove(int storeId) => caller.callServerEndpoint<void>(
    'store',
    'remove',
    {'storeId': storeId},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_i7bh5n7n.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i7bh5n7n.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_core = _iacc.Caller(client);
    serverpod_auth_idp = _iaic.Caller(client);
  }

  late final _iacc.Caller serverpod_auth_core;

  late final _iaic.Caller serverpod_auth_idp;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    basket = EndpointBasket(this);
    basketStream = EndpointBasketStream(this);
    device = EndpointDevice(this);
    history = EndpointHistory(this);
    household = EndpointHousehold(this);
    settlement = EndpointSettlement(this);
    signIn = EndpointSignIn(this);
    stats = EndpointStats(this);
    store = EndpointStore(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointBasket basket;

  late final EndpointBasketStream basketStream;

  late final EndpointDevice device;

  late final EndpointHistory history;

  late final EndpointHousehold household;

  late final EndpointSettlement settlement;

  late final EndpointSignIn signIn;

  late final EndpointStats stats;

  late final EndpointStore store;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'basket': basket,
    'basketStream': basketStream,
    'device': device,
    'history': history,
    'household': household,
    'settlement': settlement,
    'signIn': signIn,
    'stats': stats,
    'store': store,
    'greeting': greeting,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_core': modules.serverpod_auth_core,
    'serverpod_auth_idp': modules.serverpod_auth_idp,
  };
}
