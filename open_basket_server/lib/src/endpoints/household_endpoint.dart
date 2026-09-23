import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import '../services/analytics_service.dart';
import '../services/authz.dart';
import '../services/basket_service.dart';
import '../util/clock.dart';
import '../util/household_code.dart';
import '../util/money.dart';

/// Creating, joining and administering a household.
class HouseholdEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a household with a fresh code and makes the caller its owner.
  ///
  /// Throws `alreadyInAHousehold` if the caller is already in one: a user
  /// belongs to exactly one household at a time, which is what lets every
  /// other endpoint work out which household they mean without being told.
  Future<Household> create(Session session, String name) async {
    await _requireNoHousehold(session);
    final displayName = await _displayNameFor(session);

    return session.db.transaction((final transaction) async {
      final household = await Household.db.insertRow(
        session,
        Household(
          name: _requireName(name),
          code: await _unusedCode(session, transaction: transaction),
        ),
        transaction: transaction,
      );

      await HouseholdMember.db.insertRow(
        session,
        HouseholdMember(
          householdId: household.id!,
          userId: Authz.userId(session),
          displayName: displayName,
          role: MemberRole.owner,
        ),
        transaction: transaction,
      );

      await AnalyticsService.track(
        session,
        AnalyticsType.householdCreated,
        householdId: household.id,
      );
      return household;
    });
  }

  /// The caller's household, or null when they have not joined one. The client
  /// turns a null into "Create or join".
  Future<Household?> getMine(Session session) async {
    final member = await Authz.currentMember(session);
    if (member == null) return null;
    return Household.db.findById(session, member.householdId);
  }

  /// Joins by code.
  ///
  /// Throws `unknownHouseholdCode` for a typo and for a code that has been
  /// rotated away. The client words those two differently, but the server must
  /// not confirm that a code once existed — that is the difference between a
  /// hint and an oracle.
  Future<Household> joinWithCode(Session session, String code) async {
    await _requireNoHousehold(session);

    if (!HouseholdCode.isWellFormed(code)) {
      throw OpenBasketException(
        error: BasketError.unknownHouseholdCode,
        message: 'No household with that code.',
      );
    }

    final household = await Household.db.findFirstRow(
      session,
      where: (final t) => t.code.equals(HouseholdCode.normalize(code)),
    );
    if (household == null) {
      throw OpenBasketException(
        error: BasketError.unknownHouseholdCode,
        message: 'No household with that code.',
      );
    }

    // Someone coming back gets their old row back rather than a second one:
    // the unique index is per household and user, and their history is
    // already attached to that row (ADR-036).
    final previous = await HouseholdMember.db.findFirstRow(
      session,
      where: (final t) =>
          t.householdId.equals(household.id!) &
          t.userId.equals(Authz.userId(session)),
    );
    final member = previous != null
        ? await HouseholdMember.db.updateRow(
            session,
            previous.copyWith(leftAt: null, role: MemberRole.member),
          )
        : await HouseholdMember.db.insertRow(
            session,
            HouseholdMember(
              householdId: household.id!,
              userId: Authz.userId(session),
              displayName: await _displayNameFor(session),
              role: MemberRole.member,
            ),
          );
    await AnalyticsService.track(
      session,
      AnalyticsType.memberJoined,
      householdId: household.id,
      memberId: member.id,
    );
    return household;
  }

  /// Issues a new code and kills the old one immediately (ADR-006).
  ///
  /// Owner only. Everyone already in stays in and nothing in history changes —
  /// only new joins are affected, which is the whole point of rotating.
  Future<Household> rotateCode(Session session) async {
    final owner = await Authz.requireOwner(session);
    final household = (await Household.db.findById(
      session,
      owner.householdId,
    ))!;

    return Household.db.updateRow(
      session,
      household.copyWith(code: await _unusedCode(session)),
    );
  }

  /// Everyone in the household, longest-standing first. With
  /// `includeFormer` also the people who have left (their `leftAt` is set),
  /// so history can still name who asked for what and who paid whom.
  ///
  /// Nullable rather than defaulted, for the same generated-client reason as
  /// `addItem`'s quantity.
  Future<List<HouseholdMember>> listMembers(
    Session session, {
    bool? includeFormer,
  }) async {
    final member = await Authz.requireMember(session);
    return HouseholdMember.db.find(
      session,
      where: (final t) => includeFormer == true
          ? t.householdId.equals(member.householdId)
          : t.householdId.equals(member.householdId) & t.leftAt.equals(null),
      orderBy: (final t) => t.joinedAt,
    );
  }

  /// Owner only.
  Future<Household> rename(Session session, String name) async {
    final owner = await Authz.requireOwner(session);
    final household = (await Household.db.findById(
      session,
      owner.householdId,
    ))!;
    return Household.db.updateRow(
      session,
      household.copyWith(name: _requireName(name)),
    );
  }

  /// Owner only. ISO 4217.
  ///
  /// Never converts anything: a settled basket keeps the code it closed with,
  /// so changing this only affects what happens next (ADR-008).
  Future<Household> setCurrency(Session session, String currencyCode) async {
    final owner = await Authz.requireOwner(session);
    final code = currencyCode.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
      throw OpenBasketException(
        error: BasketError.invalidCurrency,
        message: 'That is not a currency code.',
      );
    }

    final household = (await Household.db.findById(
      session,
      owner.householdId,
    ))!;
    return Household.db.updateRow(
      session,
      household.copyWith(currencyCode: code),
    );
  }

  /// How many minor units make one major unit for the household's currency —
  /// 2 for lira, 0 for yen. The client needs it to format and to show the
  /// receipt gap in the right granularity.
  Future<int> currencyMinorUnitDigits(Session session) async {
    final member = await Authz.requireMember(session);
    final household = (await Household.db.findById(
      session,
      member.householdId,
    ))!;
    return Money.minorUnitDigits(household.currencyCode);
  }

  /// The caller's own three notification switches (ADR-010). Checked on the
  /// server before anything is sent, so turning one off actually stops the
  /// push rather than hiding it.
  Future<HouseholdMember> setNotificationPreferences(
    Session session, {
    required bool basketOpened,
    required bool closingSoon,
    required bool settlementReady,
  }) async {
    final member = await Authz.requireMember(session);
    return HouseholdMember.db.updateRow(
      session,
      member.copyWith(
        notifyBasketOpened: basketOpened,
        notifyClosingSoon: closingSoon,
        notifySettlementReady: settlementReady,
      ),
    );
  }

  /// Leaves the household. The caller loses access to its history; the
  /// household keeps it (ADR-036).
  ///
  /// The row is marked, not deleted. Deleting it cascaded into the member's
  /// items, their settlement lines and every basket they had shopped — the
  /// immutable history of rule 6, and the data the report is built from.
  ///
  /// The shopper of a basket that is still open or at the checkout cannot
  /// leave: nobody else may extend, price or settle it (rule 3).
  ///
  /// An owner who leaves hands ownership to the longest-standing member left,
  /// so a household can never end up with nobody able to rotate the code or
  /// change the currency.
  Future<void> leave(Session session) async {
    final member = await Authz.requireMember(session);

    final running = await BasketService.activeFor(session, member.householdId);
    if (running != null && running.shopperMemberId == member.id) {
      throw OpenBasketException(
        error: BasketError.shopperCannotLeave,
        message: 'Finish or cancel your basket before you leave.',
      );
    }

    await session.db.transaction((final transaction) async {
      await HouseholdMember.db.updateRow(
        session,
        member.copyWith(leftAt: ServerClock.now(), role: MemberRole.member),
        transaction: transaction,
      );

      if (member.role != MemberRole.owner) return;

      final remaining = await HouseholdMember.db.find(
        session,
        where: (final t) =>
            t.householdId.equals(member.householdId) & t.leftAt.equals(null),
        orderBy: (final t) => t.joinedAt,
        limit: 1,
        transaction: transaction,
      );
      final heir = remaining.firstOrNull;
      if (heir == null) return;

      await HouseholdMember.db.updateRow(
        session,
        heir.copyWith(role: MemberRole.owner),
        transaction: transaction,
      );
    });
  }

  // ---------------------------------------------------------------- helpers

  static String _requireName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 60) {
      throw OpenBasketException(
        error: BasketError.invalidHouseholdName,
        message: 'Give the household a name.',
      );
    }
    return trimmed;
  }

  Future<void> _requireNoHousehold(Session session) async {
    if (await Authz.currentMember(session) != null) {
      throw OpenBasketException(
        error: BasketError.alreadyInAHousehold,
        message: 'You can be in one household at a time.',
      );
    }
  }

  /// A code nothing is using yet.
  ///
  /// 33^6 is roughly 1.3 billion, so a collision is vanishingly unlikely — but
  /// the column is unique, and an insert that throws because two households
  /// drew the same code would be a baffling failure to debug at 18:40 in a
  /// supermarket.
  Future<String> _unusedCode(
    Session session, {
    Transaction? transaction,
  }) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = HouseholdCode.generate();
      final taken = await Household.db.findFirstRow(
        session,
        where: (final t) => t.code.equals(code),
        transaction: transaction,
      );
      if (taken == null) return code;
    }
    throw StateError('Could not find an unused household code in 5 tries');
  }

  /// What to show on item rows and person chips.
  ///
  /// The profile's name if it has one, otherwise the part of the email before
  /// the @ — better than a blank chip, and the member can be renamed later.
  Future<String> _displayNameFor(Session session) async {
    final profile = await AuthServices.instance.userProfiles
        .maybeFindUserProfileByUserId(session, Authz.userId(session));
    final named = profile?.fullName ?? profile?.userName;
    if (named != null && named.trim().isNotEmpty) return named.trim();

    final email = profile?.email;
    if (email != null && email.contains('@')) {
      return email.substring(0, email.indexOf('@'));
    }
    return 'Member';
  }
}
