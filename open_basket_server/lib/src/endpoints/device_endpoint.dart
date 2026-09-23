import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/authz.dart';
import '../util/clock.dart';

/// FCM registration tokens. Which of the three notification types actually go
/// out is a per-member preference on `HouseholdMember` (ADR-010), checked on
/// the server before sending (ADR-043).
class DeviceEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Idempotent: re-registering an existing token refreshes it. A token that
  /// belonged to someone else moves to the caller — one phone, one person
  /// signed in, and the previous person must stop getting this phone's
  /// notifications the moment someone else signs in on it.
  Future<DeviceToken> registerToken(Session session, String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty || trimmed.length > 4096) {
      throw OpenBasketException(
        error: BasketError.invalidDeviceToken,
        message: 'That is not a device token.',
      );
    }
    final userId = Authz.userId(session);
    final now = ServerClock.now();
    final existing = await DeviceToken.db.findFirstRow(
      session,
      where: (t) => t.token.equals(trimmed),
    );
    if (existing != null) {
      return DeviceToken.db.updateRow(
        session,
        existing.copyWith(userId: userId, updatedAt: now),
      );
    }
    try {
      return await DeviceToken.db.insertRow(
        session,
        DeviceToken(userId: userId, token: trimmed, updatedAt: now),
      );
    } on DatabaseUniqueViolationException {
      // Registered by a parallel call a moment ago: take it over instead.
      final row = (await DeviceToken.db.findFirstRow(
        session,
        where: (t) => t.token.equals(trimmed),
      ))!;
      return DeviceToken.db.updateRow(
        session,
        row.copyWith(userId: userId, updatedAt: now),
      );
    }
  }

  /// Called on sign-out, so a shared phone stops receiving another member's
  /// notifications. Only the caller's own token can be removed; anything else
  /// is quietly nothing.
  Future<void> removeToken(Session session, String token) async {
    final userId = Authz.userId(session);
    await DeviceToken.db.deleteWhere(
      session,
      where: (t) => t.token.equals(token.trim()) & t.userId.equals(userId),
    );
  }
}
