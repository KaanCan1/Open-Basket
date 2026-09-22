import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/authz.dart';

/// Past runs.
class HistoryEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// The household's finished runs, newest first. Settled and cancelled runs
  /// both appear; a run that is still open or frozen is not history yet and
  /// is `basket.getActive`'s to answer.
  ///
  /// `limit` is clamped to 1..[maxLimit]. It is nullable for the same reason
  /// as `addItem`'s quantity: a defaulted named parameter becomes a required
  /// one on the generated client.
  Future<List<Basket>> list(Session session, {int? limit}) async {
    final member = await Authz.requireMember(session);
    return Basket.db.find(
      session,
      where: (t) =>
          t.householdId.equals(member.householdId) &
          t.status.inSet({BasketStatus.settled, BasketStatus.cancelled}),
      // Newest by when the run started: a settled basket has no settledAt.
      // A frozen run can overlap the next one (ADR-025), so this is not
      // strictly finish order, but it is the order the house shopped in.
      orderBy: (t) => t.openedAt.desc(),
      limit: (limit ?? defaultLimit).clamp(1, maxLimit),
    );
  }

  static const defaultLimit = 20;
  static const maxLimit = 50;

  /// One past run in full: its items with who asked and what they cost, and
  /// its settlement lines if it has any. A cancelled run has neither prices
  /// nor lines. Read-only.
  Future<BasketEvent> get(Session session, int basketId) async {
    throw UnimplementedError('Day 21');
  }
}
