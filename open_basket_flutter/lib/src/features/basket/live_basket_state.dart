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

/// Something added while this phone could not reach the server (ADR-011).
/// Held here, shown as a dashed row, and sent in order once the stream is
/// back.
class QueuedItem {
  const QueuedItem({
    required this.name,
    required this.queuedAt,
    this.note,
    this.quantity,
    this.unit,
  });

  final String name;
  final String? note;
  final int? quantity;
  final ItemUnit? unit;

  /// Local time, for display only.
  final DateTime queuedAt;
}

/// What happened to the queue the last time it was sent, for the "back
/// online" strip. Cleared a few seconds later.
class QueueReport {
  const QueueReport({this.sent = const [], this.dropped = const []});

  /// Names that reached the server.
  final List<String> sent;

  /// Names that could not be sent because the basket closed meanwhile.
  final List<String> dropped;

  bool get isEmpty => sent.isEmpty && dropped.isEmpty;
}

class LiveBasketState {
  const LiveBasketState({
    required this.connection,
    this.basket,
    this.items = const [],
    this.queued = const [],
    this.report,
    this.lastSyncedAt,
  });

  const LiveBasketState.connecting()
    : this(connection: LiveConnection.connecting);

  final LiveConnection connection;
  final Basket? basket;

  /// In the order the server sent them, oldest first.
  final List<BasketItem> items;

  /// Added on this phone while offline, not yet on the server, oldest first.
  final List<QueuedItem> queued;

  /// The outcome of the last time the queue was sent, while it is on screen.
  final QueueReport? report;

  /// Local time of the last event from the server — the "last synced" line
  /// while reconnecting.
  final DateTime? lastSyncedAt;

  bool get isOpen => basket?.status == BasketStatus.open;

  /// [report] is replaced rather than merged: pass [clearReport] to take the
  /// strip down.
  LiveBasketState copyWith({
    LiveConnection? connection,
    Basket? basket,
    List<BasketItem>? items,
    List<QueuedItem>? queued,
    QueueReport? report,
    bool clearReport = false,
    DateTime? lastSyncedAt,
  }) {
    return LiveBasketState(
      connection: connection ?? this.connection,
      basket: basket ?? this.basket,
      items: items ?? this.items,
      queued: queued ?? this.queued,
      report: clearReport ? null : report ?? this.report,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  LiveBasketState enqueue(QueuedItem item) =>
      copyWith(queued: [...queued, item]);

  /// Drops the oldest queued item, the one that was just sent.
  LiveBasketState dequeue() =>
      copyWith(queued: queued.isEmpty ? queued : queued.sublist(1));

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
