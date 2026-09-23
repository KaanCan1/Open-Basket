import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';

/// Membership and role checks.
///
/// Rule 3: every endpoint checks authorization. These are the checks, in one
/// place, so no endpoint has to remember how to spell them — and so a reviewer
/// can see at a glance which endpoints guard what.
///
/// Each one returns the row it just proved exists, so the caller does not load
/// it twice.
abstract final class Authz {
  /// The signed-in user. `requireLogin` on the endpoint has already run, so a
  /// missing id here means a bug rather than an anonymous caller.
  static UuidValue userId(Session session) {
    final id = session.authenticated?.authUserId;
    if (id == null) {
      throw StateError('Authz used on an endpoint without requireLogin');
    }
    return id;
  }

  /// The caller's membership, whichever household it is in. A user belongs to
  /// one household at a time, so this is unambiguous.
  ///
  /// Returns null when they have not joined one — the router turns that into
  /// "Create or join".
  static Future<HouseholdMember?> currentMember(Session session) {
    final id = userId(session);
    // Former memberships stay as rows (ADR-036); only a current one counts.
    return HouseholdMember.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(id) & t.leftAt.equals(null),
    );
  }

  /// The caller's membership, or `notAMember`.
  static Future<HouseholdMember> requireMember(Session session) async {
    final member = await currentMember(session);
    if (member == null) {
      throw OpenBasketException(
        error: BasketError.notAMember,
        message: 'Join a household first.',
      );
    }
    return member;
  }

  /// Membership of one specific household. Use this whenever an id arrives
  /// from the client: being in *a* household is not permission to touch
  /// *this* one.
  static Future<HouseholdMember> requireMemberOf(
    Session session,
    int householdId,
  ) async {
    final member = await requireMember(session);
    if (member.householdId != householdId) {
      throw OpenBasketException(
        error: BasketError.notAMember,
        message: 'That household is not yours.',
      );
    }
    return member;
  }

  /// Owner-only actions: rotating the code, renaming, changing the currency.
  static Future<HouseholdMember> requireOwner(Session session) async {
    final member = await requireMember(session);
    if (member.role != MemberRole.owner) {
      throw OpenBasketException(
        error: BasketError.notTheOwner,
        message: 'Only the household owner can do that.',
      );
    }
    return member;
  }

  /// Shopper-only actions: extend, freeze, mark items, enter prices, settle,
  /// cancel. Also proves the basket belongs to the caller's household, so an
  /// endpoint that calls this needs no separate membership check.
  static Future<HouseholdMember> requireShopper(
    Session session,
    Basket basket,
  ) async {
    final member = await requireMemberOf(session, basket.householdId);
    if (basket.shopperMemberId != member.id) {
      throw OpenBasketException(
        error: BasketError.notTheShopper,
        message: 'Only the person shopping can do that.',
      );
    }
    return member;
  }
}
