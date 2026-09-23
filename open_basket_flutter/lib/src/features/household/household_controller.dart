import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/client_provider.dart';

/// The caller's household, or null when they have not joined one.
///
/// The router does not read this — it only knows signed in or not. Screen 04
/// is reached by the home screen resolving to null, which keeps the redirect
/// synchronous and avoids a flash of the wrong screen while a future settles.
final myHouseholdProvider = FutureProvider<Household?>((final ref) async {
  return ref.watch(clientProvider).household.getMine();
});

/// Everyone who has ever been in the caller's household, longest-standing
/// first — former members included (their `leftAt` is set), because history,
/// settlements and item rows still have to name them (ADR-036).
///
/// Anything that counts or lists the household as it is now wants
/// [activeMembersProvider] instead.
final membersProvider = FutureProvider<List<HouseholdMember>>((
  final ref,
) async {
  // Rebuilds when the household changes, so joining or creating one does not
  // leave a stale member list behind.
  final household = await ref.watch(myHouseholdProvider.future);
  if (household == null) return const [];
  return ref.watch(clientProvider).household.listMembers(includeFormer: true);
});

/// The people in the household now.
final activeMembersProvider = FutureProvider<List<HouseholdMember>>((
  final ref,
) async {
  final members = await ref.watch(membersProvider.future);
  return [
    for (final m in members)
      if (m.leftAt == null) m,
  ];
});

/// The caller's own membership row, which is how a screen knows which member
/// is "you" without another call.
final myMembershipProvider = FutureProvider<HouseholdMember?>((
  final ref,
) async {
  final members = await ref.watch(activeMembersProvider.future);
  final userId = currentUserId(ref.watch(clientProvider));
  if (userId == null) return null;
  for (final member in members) {
    if (member.userId == userId) return member;
  }
  return null;
});

class HouseholdController {
  const HouseholdController(this._ref);

  final Ref _ref;

  Client get _client => _ref.read(clientProvider);

  Future<Household> create(String name) async {
    final household = await _client.household.create(name);
    _invalidate();
    return household;
  }

  Future<Household> joinWithCode(String code) async {
    final household = await _client.household.joinWithCode(code);
    _invalidate();
    return household;
  }

  Future<Household> rotateCode() async {
    final household = await _client.household.rotateCode();
    _invalidate();
    return household;
  }

  /// Owner only.
  Future<Household> rename(String name) async {
    final household = await _client.household.rename(name);
    _invalidate();
    return household;
  }

  /// Owner only. Never converts anything already priced (ADR-008).
  Future<Household> setCurrency(String currencyCode) async {
    final household = await _client.household.setCurrency(currencyCode);
    _invalidate();
    return household;
  }

  /// The caller leaves; the household keeps its history (ADR-036).
  Future<void> leave() async {
    await _client.household.leave();
    _invalidate();
  }

  /// Both providers, because the member list hangs off the household and a
  /// screen that refreshed only one would show a new household with the old
  /// household's members for a frame.
  void _invalidate() {
    _ref.invalidate(myHouseholdProvider);
    _ref.invalidate(membersProvider);
  }
}

final householdControllerProvider = Provider<HouseholdController>(
  HouseholdController.new,
);
