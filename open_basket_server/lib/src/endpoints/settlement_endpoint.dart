import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Working out who owes whom. The arithmetic lives in
/// `services/settlement_service.dart` as a pure function so it can be tested
/// without a database.
class SettlementEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// What settling would produce, without writing anything. Lets the checkout
  /// screen show the split before the shopper commits.
  Future<List<SettlementLine>> preview(Session session, int basketId) async {
    throw UnimplementedError('Day 17-18');
  }

  /// Writes the lines and moves the basket to `settled`. Shopper only.
  ///
  /// Each member owes their own picked items plus an even share of the gap
  /// between the receipt total and the item sum — every member, including one
  /// who asked for nothing. The remainder goes to the shopper so the lines
  /// always sum to exactly what they paid (ADR-007).
  ///
  /// Throws `basketNotFrozen` too early and `basketAlreadySettled` twice: the
  /// result is immutable.
  Future<List<SettlementLine>> settle(Session session, int basketId) async {
    throw UnimplementedError('Day 17-18');
  }

  Future<List<SettlementLine>> get(Session session, int basketId) async {
    throw UnimplementedError('Day 17-18');
  }
}
