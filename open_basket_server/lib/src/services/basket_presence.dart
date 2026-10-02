/// Who has a basket on screen right now (ADR-049).
///
/// Counted per open stream rather than per member, so a member with the
/// basket open on a phone and a tablet stays "looking" until both close.
///
/// In memory, on purpose. Presence is only true for as long as a connection
/// is, and a connection lives in exactly one server process; persisting it
/// would mean cleaning up after every crash for a line of copy. Like
/// `BasketChannels`, this is local to one instance — a second instance would
/// need Redis for both.
abstract final class BasketPresence {
  static final _streams = <int, Map<int, int>>{};

  /// A stream for [memberId] on [basketId] opened.
  static void enter(int basketId, int memberId) {
    final members = _streams.putIfAbsent(basketId, () => {});
    members[memberId] = (members[memberId] ?? 0) + 1;
  }

  /// A stream for [memberId] on [basketId] closed.
  static void leave(int basketId, int memberId) {
    final members = _streams[basketId];
    if (members == null) return;
    final left = (members[memberId] ?? 1) - 1;
    if (left <= 0) {
      members.remove(memberId);
    } else {
      members[memberId] = left;
    }
    if (members.isEmpty) _streams.remove(basketId);
  }

  /// Member ids looking at [basketId], smallest first so every phone draws
  /// the avatars in the same order.
  static List<int> viewers(int basketId) =>
      (_streams[basketId]?.keys.toList() ?? <int>[])..sort();

  /// For tests.
  static void reset() => _streams.clear();
}
