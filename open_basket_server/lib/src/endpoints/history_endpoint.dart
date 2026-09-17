import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Past runs.
class HistoryEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Newest first. Settled and cancelled runs both appear.
  Future<List<Basket>> list(Session session, {int limit = 20}) async {
    throw UnimplementedError('Day 21');
  }

  /// One past run in full: its items with who asked and what they cost, and
  /// its settlement lines if it has any. A cancelled run has neither prices
  /// nor lines. Read-only.
  Future<BasketEvent> get(Session session, int basketId) async {
    throw UnimplementedError('Day 21');
  }
}
