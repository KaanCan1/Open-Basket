import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// FCM registration tokens. Which of the three notification types actually go
/// out is a per-member preference on `HouseholdMember` (ADR-010), checked on
/// the server before sending.
class DeviceEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Idempotent: re-registering an existing token refreshes it.
  Future<DeviceToken> registerToken(Session session, String token) async {
    throw UnimplementedError('Day 11-12');
  }

  /// Called on sign-out, so a shared phone stops receiving another member's
  /// notifications.
  Future<void> removeToken(Session session, String token) async {
    throw UnimplementedError('Day 11-12');
  }
}
