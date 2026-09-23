import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/client_provider.dart';

/// Finished runs, newest first. Fifty is more than a household shops in the
/// weeks this app has been running; the header's totals are over these.
final historyProvider = FutureProvider<List<PastRun>>((final ref) async {
  return ref.watch(clientProvider).history.list(limit: 50);
});

/// One past run in full: its basket and items, and its settlement lines if it
/// was settled.
final pastRunProvider = FutureProvider.autoDispose
    .family<({BasketEvent run, List<SettlementLine> lines}), int>((
      final ref,
      final basketId,
    ) async {
      final client = ref.watch(clientProvider);
      final run = await client.history.get(basketId);
      final lines = run.basket?.status == BasketStatus.settled
          ? await client.settlement.get(basketId)
          : const <SettlementLine>[];
      return (run: run, lines: lines);
    });
