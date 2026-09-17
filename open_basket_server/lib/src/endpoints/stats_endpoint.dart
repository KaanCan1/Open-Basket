import 'package:serverpod/serverpod.dart';

/// Numbers for the Day 26 report, read out of `analytics_event`. Everything
/// here depends on events having been written since Day 2 — a metric added
/// later is data already lost.
class StatsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Baskets opened, items per basket, how runs ended (auto-closed, frozen by
  /// hand, cancelled, settled), average chosen duration, extension rate,
  /// median time from open to first item, and the share of members who added
  /// at least one item — the headline metric, "shared attention".
  ///
  /// Returns JSON so the report script can grow new metrics without a model
  /// change.
  Future<String> report(Session session) async {
    throw UnimplementedError('Day 26');
  }
}
