import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Creating, joining and administering a household.
class HouseholdEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a household with a fresh six-character code and makes the caller
  /// its owner. Throws `alreadyInAHousehold` if the caller is already in one.
  Future<Household> create(Session session, String name) async {
    throw UnimplementedError('Day 5-6');
  }

  /// The caller's household, or null if they have not joined one yet. The
  /// router sends a null here to "Create or join".
  Future<Household?> getMine(Session session) async {
    throw UnimplementedError('Day 5-6');
  }

  /// Joins by code. Throws `unknownHouseholdCode` for both a typo and a code
  /// that has been rotated away — the client words those differently but the
  /// server must not confirm that a code once existed.
  Future<Household> joinWithCode(Session session, String code) async {
    throw UnimplementedError('Day 5-6');
  }

  /// Issues a new code and kills the old one immediately (ADR-006). Owner only.
  /// Existing members are unaffected and nothing in history changes.
  Future<Household> rotateCode(Session session) async {
    throw UnimplementedError('Day 5-6');
  }

  Future<List<HouseholdMember>> listMembers(Session session) async {
    throw UnimplementedError('Day 5-6');
  }

  /// Owner only.
  Future<Household> rename(Session session, String name) async {
    throw UnimplementedError('Day 22-23');
  }

  /// Owner only. ISO 4217. Never converts anything: settled baskets keep the
  /// code they closed with (ADR-008).
  Future<Household> setCurrency(Session session, String currencyCode) async {
    throw UnimplementedError('Day 22-23');
  }

  /// The caller's own three notification switches (ADR-010).
  Future<HouseholdMember> setNotificationPreferences(
    Session session, {
    required bool basketOpened,
    required bool closingSoon,
    required bool settlementReady,
  }) async {
    throw UnimplementedError('Day 11-12');
  }

  /// Leaves the household. The caller loses access to its history.
  Future<void> leave(Session session) async {
    throw UnimplementedError('Day 5-6');
  }
}
