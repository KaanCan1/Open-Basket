import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/client_provider.dart';

/// The household's basket that is still going, or null.
///
/// This is what a cold start reads to discover that a basket is open, or that
/// one closed while the app was away.
final activeBasketProvider = FutureProvider<Basket?>((final ref) async {
  return ref.watch(clientProvider).basket.getActive();
});

class BasketController {
  const BasketController(this._ref);

  final Ref _ref;

  Client get _client => _ref.read(clientProvider);

  Future<Basket> open({required int durationMinutes, int? storeId}) async {
    final basket = await _client.basket.open(
      storeId: storeId,
      durationMinutes: durationMinutes,
    );
    _ref.invalidate(activeBasketProvider);
    return basket;
  }

  /// Extend, freeze and cancel do not invalidate anything: the stream carries
  /// the new basket to every watcher including this one, and invalidating as
  /// well would refetch what is already arriving.
  Future<Basket> extend(int basketId) => _client.basket.extend(basketId);

  Future<Basket> freeze(int basketId) => _client.basket.freeze(basketId);

  Future<Basket> cancel(int basketId) async {
    final basket = await _client.basket.cancel(basketId);
    _ref.invalidate(activeBasketProvider);
    return basket;
  }

  Future<BasketItem> addItem(
    int basketId,
    String name, {
    int? quantity,
    String? note,
  }) {
    return _client.basket.addItem(
      basketId,
      name,
      quantity: quantity,
      note: note,
    );
  }

  Future<void> removeItem(int itemId) => _client.basket.removeItem(itemId);

  /// Shopper only. Like extend and freeze, the result reaches this screen
  /// through the stream, so nothing is invalidated here.
  Future<BasketItem> markItem(
    int itemId,
    ItemStatus status, {
    int? priceMinor,
  }) => _client.basket.markItem(itemId, status, priceMinor: priceMinor);

  Future<Basket> setReceiptTotal(int basketId, int totalMinor) =>
      _client.basket.setReceiptTotal(basketId, totalMinor);

  /// Settling ends the run, so the home screen's basket goes too.
  Future<List<SettlementLine>> settle(int basketId) async {
    final lines = await _client.settlement.settle(basketId);
    _ref.invalidate(activeBasketProvider);
    _ref.invalidate(lastSettledRunProvider);
    _ref.invalidate(settlementProvider(basketId));
    return lines;
  }
}

/// The household's most recent finished run, but only when it was settled,
/// with its lines. Null when there is none, or when the last run was
/// cancelled — a cancelled run owes nobody anything and has nothing to show.
///
/// This is how a member who was not watching the live basket finds out what
/// they owe: the home screen shows it until the next run opens.
final lastSettledRunProvider =
    FutureProvider<({Basket basket, List<SettlementLine> lines})?>((
      final ref,
    ) async {
      final client = ref.watch(clientProvider);
      final runs = await client.history.list(limit: 1);
      if (runs.isEmpty || runs.single.status != BasketStatus.settled) {
        return null;
      }
      final basket = runs.single;
      return (
        basket: basket,
        lines: await client.settlement.get(basket.id!),
      );
    });

/// The stored lines of a settled basket; empty for any other.
final settlementProvider = FutureProvider.autoDispose
    .family<List<SettlementLine>, int>((final ref, final basketId) async {
      return ref.watch(clientProvider).settlement.get(basketId);
    });

final basketControllerProvider = Provider<BasketController>(
  BasketController.new,
);
