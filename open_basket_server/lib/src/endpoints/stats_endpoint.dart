import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../services/authz.dart';
import '../services/stats_service.dart';

/// Numbers for the Day 26 report (ADR-040).
///
/// Only ever the caller's own household. Every household's numbers together
/// are an operator's question, answered by `scripts/report.sql` against the
/// database — not by an endpoint any signed-in account, a judge's included,
/// could call to count how many houses use the app and how they shop.
class StatsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Baskets opened, items per basket, how runs ended (auto-closed, frozen by
  /// hand, cancelled, settled), average chosen duration, extension rate,
  /// median time from open to first item, and the share of members who added
  /// at least one item — the headline metric, "shared attention". The field
  /// meanings are on [StatsService.headlineSql].
  ///
  /// Returns JSON so the report can grow new metrics without a model change.
  Future<String> report(Session session) async {
    final member = await Authz.requireMember(session);
    return jsonEncode(
      await StatsService.headline(session, householdId: member.householdId),
    );
  }
}
