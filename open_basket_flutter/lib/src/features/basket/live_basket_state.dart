import 'package:open_basket_client/open_basket_client.dart';

/// How the live basket is doing, as far as the screen needs to know.
enum LiveConnection {
  /// Waiting for the first snapshot. The screen has nothing to draw yet.
  connecting,

  /// Events are arriving.
  live,

  /// The stream dropped and a retry is pending. What is on screen is the last
  /// snapshot plus whatever arrived before the drop, so it stays readable —
  /// it is just no longer known to be current, and the screen says so.
  reconnecting,

  /// The basket reached a state nothing more can happen in, and the server
  /// closed the stream. Not an error, and not something to reconnect to.
  over,
}

class LiveBasketState {
  const LiveBasketState({
    required this.connection,
    this.basket,
    this.items = const [],
  });

  const LiveBasketState.connecting()
    : this(connection: LiveConnection.connecting);

  final LiveConnection connection;
  final Basket? basket;

  /// In the order the server sent them, oldest first.
  final List<BasketItem> items;

  bool get isOpen => basket?.status == BasketStatus.open;

  LiveBasketState copyWith({
    LiveConnection? connection,
    Basket? basket,
    List<BasketItem>? items,
  }) {
    return LiveBasketState(
      connection: connection ?? this.connection,
      basket: basket ?? this.basket,
      items: items ?? this.items,
    );
  }

  /// Applies an item event by id rather than by appending.
  ///
  /// ADR-016: the server subscribes before it reads the snapshot, so an
  /// `itemAdded` for a row the snapshot already carried is normal rather than
  /// exceptional. Appending would double it. Dropping events is
  /// unrecoverable; applying one twice must not be.
  LiveBasketState withItem(BasketItem item) {
    final next = [...items];
    final at = next.indexWhere((final it) => it.id == item.id);
    if (at == -1) {
      next.add(item);
    } else {
      next[at] = item;
    }
    return copyWith(items: next);
  }

  LiveBasketState withoutItem(int itemId) {
    return copyWith(
      items: [
        for (final item in items)
          if (item.id != itemId) item,
      ],
    );
  }
}
