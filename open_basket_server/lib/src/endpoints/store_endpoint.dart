import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Shops the household uses. Only a store's own fixed location is ever stored;
/// nobody's live position reaches the server (ADR-002).
class StoreEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// `lat`/`lng` are null when the member skipped the location step, in which
  /// case the client stops suggesting a duration and defaults to 10 minutes.
  Future<Store> add(
    Session session,
    String name, {
    double? lat,
    double? lng,
  }) async {
    throw UnimplementedError('Day 7');
  }

  Future<List<Store>> list(Session session) async {
    throw UnimplementedError('Day 7');
  }

  /// Baskets that already used this store keep working: the relation is
  /// `onDelete=SetNull`, so history does not lose its rows.
  Future<void> remove(Session session, int storeId) async {
    throw UnimplementedError('Day 7');
  }
}
