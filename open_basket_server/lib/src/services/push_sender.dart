import 'dart:async';
import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

import 'notification_copy.dart';

/// What happened to one push.
enum PushOutcome {
  sent,

  /// FCM says the token is dead — the app was uninstalled or the token
  /// rotated. The caller deletes it so it is never tried again.
  tokenGone,

  failed,
}

/// Delivers one message to one device. Behind an interface so tests can see
/// exactly what would have gone out without a Firebase project, and so a
/// server with no credentials sends nothing instead of failing (ADR-043).
abstract class PushSender {
  Future<PushOutcome> send(Session session, String token, PushMessage message);
}

/// Which sender this server uses.
abstract final class PushSenders {
  /// The `passwords.yaml` key holding the Firebase service account JSON. On
  /// Serverpod Cloud: `serverpod cloud password set fcmServiceAccountJson`.
  static const credentialsKey = 'fcmServiceAccountJson';

  /// Tests put a recording sender here.
  static PushSender? override;

  static FcmPushSender? _fcm;

  static PushSender forSession(Session session) {
    if (override != null) return override!;
    final json = session.passwords[credentialsKey];
    if (json == null || json.trim().isEmpty) return const DisabledPushSender();
    return _fcm ??= FcmPushSender(json);
  }
}

/// No credentials configured: log what would have been sent and move on.
/// Opening a basket must never fail because push is not set up yet.
class DisabledPushSender implements PushSender {
  const DisabledPushSender();

  @override
  Future<PushOutcome> send(
    Session session,
    String token,
    PushMessage message,
  ) async {
    session.log(
      'push is not configured (no ${PushSenders.credentialsKey}); '
      'skipped ${message.type} for basket ${message.basketId}',
      level: LogLevel.debug,
    );
    return PushOutcome.failed;
  }
}

/// FCM HTTP v1. The OAuth client is minted once from the service account and
/// refreshes itself; every send is one POST.
class FcmPushSender implements PushSender {
  FcmPushSender(String serviceAccountJson)
    : _credentials = ServiceAccountCredentials.fromJson(serviceAccountJson),
      _projectId =
          (jsonDecode(serviceAccountJson) as Map<String, dynamic>)['project_id']
              as String;

  static const _scope = 'https://www.googleapis.com/auth/firebase.messaging';
  static const _timeout = Duration(seconds: 5);

  final ServiceAccountCredentials _credentials;
  final String _projectId;
  Future<AutoRefreshingAuthClient>? _client;

  Future<AutoRefreshingAuthClient> get _authClient =>
      _client ??= clientViaServiceAccount(_credentials, const [_scope]);

  @override
  Future<PushOutcome> send(
    Session session,
    String token,
    PushMessage message,
  ) async {
    try {
      final client = await _authClient.timeout(_timeout);
      final response = await client
          .post(
            Uri.parse(
              'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
            ),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'message': {
                'token': token,
                'notification': {
                  'title': message.title,
                  'body': message.body,
                },
                'data': message.data,
                'android': {'priority': 'high'},
                'apns': {
                  'payload': {
                    'aps': {'sound': 'default'},
                  },
                },
              },
            }),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) return PushOutcome.sent;
      if (_isGone(response)) return PushOutcome.tokenGone;
      session.log(
        'FCM refused ${message.type} for basket ${message.basketId}: '
        '${response.statusCode} ${response.body}',
        level: LogLevel.warning,
      );
      return PushOutcome.failed;
    } catch (e, stackTrace) {
      // A failed auth mint is not cached: the next send tries again.
      if (e is! http.ClientException && e is! TimeoutException) _client = null;
      session.log(
        'FCM send failed for ${message.type} on basket ${message.basketId}',
        level: LogLevel.warning,
        exception: e,
        stackTrace: stackTrace,
      );
      return PushOutcome.failed;
    }
  }

  /// 404 `UNREGISTERED`, or 400 naming the token as invalid.
  static bool _isGone(http.Response response) {
    if (response.statusCode == 404) return true;
    return response.statusCode == 400 &&
        (response.body.contains('UNREGISTERED') ||
            response.body.contains('registration token is not a valid'));
  }
}
