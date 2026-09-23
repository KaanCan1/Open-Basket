import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show KeepAliveLink;
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/client_provider.dart';
import '../../core/server_clock.dart';
import '../history/history_controller.dart';
import '../household/household_controller.dart';
import 'basket_controller.dart';
import 'live_basket_state.dart';

/// Subscribes to one basket and keeps the screen in step with it.
///
/// Everything a client needs to recover is in the stream: its first event is
/// always a full snapshot, so a reconnect resyncs from the stream itself and
/// there is no second "catch me up" call and no window where the screen is
/// connected but wrong.
class LiveBasketController extends Notifier<LiveBasketState> {
  LiveBasketController(this.basketId);

  /// Riverpod 3 hands a family's argument to the constructor rather than to
  /// `build`, which is why this is a field rather than a parameter.
  final int basketId;

  StreamSubscription<BasketEvent>? _subscription;
  Timer? _retry;
  Timer? _clearReport;
  int _attempt = 0;
  bool _flushing = false;
  AppLifecycleListener? _lifecycle;

  /// Held while anything is queued, so leaving the screen does not throw the
  /// queue away with the controller (the provider is autoDispose).
  KeepAliveLink? _queueKeepAlive;

  /// Backoff for reconnects. The first retry is quick because the common
  /// cause is a phone waking up, which resolves immediately; the ceiling
  /// keeps a genuinely down server from being hammered by every phone in
  /// every household at once.
  static const _backoff = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 20),
  ];

  @override
  LiveBasketState build() {
    ref.onDispose(_stop);
    // iOS suspends the app in the background and the socket dies with it,
    // often without an error reaching the stream — so a phone taken out of a
    // pocket showed a list that looked live and was minutes old. Coming back
    // to the foreground always resubscribes, and the snapshot that opens
    // every subscription brings the list up to date.
    _lifecycle = AppLifecycleListener(onResume: resync);
    _connect();
    return const LiveBasketState.connecting();
  }

  void _stop() {
    _retry?.cancel();
    _retry = null;
    _clearReport?.cancel();
    _clearReport = null;
    _subscription?.cancel();
    _subscription = null;
    _lifecycle?.dispose();
    _lifecycle = null;
  }

  /// Drops whatever connection there is and subscribes again straight away,
  /// skipping any backoff that was pending.
  void resync() {
    if (state.connection == LiveConnection.over) return;
    _retry?.cancel();
    _retry = null;
    _attempt = 0;
    _connect();
  }

  /// Adds an item, or queues it on this phone when the server cannot be
  /// reached (ADR-011). Returns true when it was queued rather than sent.
  ///
  /// A refusal from the server — the basket closed, the name is empty — is
  /// not a connection problem and is rethrown for the add bar to show.
  Future<bool> add(
    String name, {
    String? note,
    int? quantity,
    ItemUnit? unit,
  }) async {
    final queued = QueuedItem(
      name: name,
      note: note,
      quantity: quantity,
      unit: unit,
      queuedAt: DateTime.now(),
    );
    if (state.connection != LiveConnection.live) {
      _enqueue(queued);
      return true;
    }
    try {
      await ref
          .read(basketControllerProvider)
          .addItem(
            basketId,
            name,
            note: note,
            quantity: quantity,
            unit: unit,
          );
      return false;
    } on OpenBasketException {
      rethrow;
    } catch (_) {
      // The stream will notice the same outage and start reconnecting; the
      // item waits for it rather than being lost with the request.
      _enqueue(queued);
      _scheduleRetry();
      return true;
    }
  }

  void _enqueue(QueuedItem item) {
    _queueKeepAlive ??= ref.keepAlive();
    state = state.enqueue(item).copyWith(clearReport: true);
  }

  /// Sends the queue in order, one at a time, once the stream is live again.
  Future<void> _flush() async {
    if (_flushing || state.queued.isEmpty) return;
    _flushing = true;
    final sent = <String>[];
    final dropped = <String>[];
    try {
      while (state.queued.isNotEmpty &&
          state.connection == LiveConnection.live) {
        final next = state.queued.first;
        try {
          await ref
              .read(basketControllerProvider)
              .addItem(
                basketId,
                next.name,
                note: next.note,
                quantity: next.quantity,
                unit: next.unit,
              );
          sent.add(next.name);
          state = state.dequeue();
        } on OpenBasketException {
          // The basket closed, or was cancelled, while this phone was away.
          // Nothing queued can be added any more; say so rather than keep
          // retrying something the server will never take.
          dropped.addAll(state.queued.map((q) => q.name));
          state = state.copyWith(queued: const []);
        } catch (_) {
          // Offline again. Keep the rest for the next reconnect.
          break;
        }
      }
    } finally {
      _flushing = false;
    }
    if (state.queued.isEmpty) {
      _queueKeepAlive?.close();
      _queueKeepAlive = null;
    }
    final report = QueueReport(sent: sent, dropped: dropped);
    if (!report.isEmpty) {
      state = state.copyWith(report: report);
      _clearReport?.cancel();
      _clearReport = Timer(const Duration(seconds: 8), () {
        state = state.copyWith(clearReport: true);
      });
    }
  }

  void _connect() {
    _subscription?.cancel();
    _subscription = ref
        .read(clientProvider)
        .basketStream
        .watch(basketId)
        .listen(
          _apply,
          onError: (Object _) => _scheduleRetry(),
          // The server ends the stream on its own once the basket is settled
          // or cancelled (ADR-017). Reconnecting to that would be a loop
          // against a server behaving correctly, so a clean close is only
          // treated as the end when the basket we hold says it is over.
          onDone: () {
            if (_isOver(state.basket?.status)) {
              state = state.copyWith(connection: LiveConnection.over);
            } else {
              _scheduleRetry();
            }
          },
        );
  }

  void _scheduleRetry() {
    _subscription?.cancel();
    _subscription = null;
    if (state.connection == LiveConnection.over) return;

    state = state.copyWith(connection: LiveConnection.reconnecting);
    final wait = _backoff[_attempt.clamp(0, _backoff.length - 1)];
    _attempt++;
    _retry?.cancel();
    _retry = Timer(wait, _connect);
  }

  void _apply(BasketEvent event) {
    // Every event carries the server's clock, so the countdown keeps
    // correcting for drift for as long as the stream is up (rule 1).
    ref.read(serverClockProvider).reconcile(event.serverTime);
    _attempt = 0;

    state = switch (event.type) {
      // copyWith rather than a fresh state: a reconnect's snapshot must not
      // throw away what is queued on this phone.
      BasketEventType.snapshot => state.copyWith(
        connection: LiveConnection.live,
        basket: event.basket,
        items: event.items ?? const [],
      ),
      BasketEventType.itemAdded || BasketEventType.itemUpdated =>
        state.copyWith(connection: LiveConnection.live).withItem(event.item!),
      BasketEventType.itemRemoved =>
        state
            .copyWith(connection: LiveConnection.live)
            .withoutItem(event.item!.id!),
      BasketEventType.timerExtended ||
      BasketEventType.basketFrozen ||
      BasketEventType.basketSettled ||
      BasketEventType.basketCancelled ||
      BasketEventType.basketUpdated => state.copyWith(
        connection: LiveConnection.live,
        basket: event.basket,
      ),
    };

    if (_isOver(state.basket?.status)) {
      state = state.copyWith(connection: LiveConnection.over);
    }

    state = state.copyWith(lastSyncedAt: DateTime.now());
    _refreshMembersIfSomeoneIsNew();
    if (event.type == BasketEventType.snapshot) unawaited(_flush());

    // The home screen reads the basket through its own provider, fetched
    // once. Without this it kept saying "a basket is open" after the stream
    // had reported the basket frozen — found by letting a basket close itself
    // in the background and then going back.
    if (event.type != BasketEventType.itemAdded &&
        event.type != BasketEventType.itemUpdated &&
        event.type != BasketEventType.itemRemoved) {
      ref.invalidate(activeBasketProvider);
      ref.invalidate(lastSettledRunProvider);
      // A run that just settled or was cancelled is history now; without this
      // the history screen kept the list it had before (found on screen 16).
      ref.invalidate(historyProvider);
    }
  }

  /// Requesters this controller has already asked the member list about, so
  /// a requester who really is gone does not refetch on every event.
  final _askedAbout = <int>{};

  /// The member list is fetched once. Someone who joined after that shows up
  /// here first, as the requester of an item nobody on this phone has heard
  /// of — and every screen that groups or labels by member would otherwise
  /// drop or mislabel that item. Found by joining a second phone while the
  /// first was on the home screen: its checkout would have hidden the new
  /// member's items and never let the shopper settle.
  void _refreshMembersIfSomeoneIsNew() {
    final members = ref.read(membersProvider).value;
    if (members == null) return;
    final known = {for (final m in members) m.id};
    final unknown = {
      for (final item in state.items)
        if (!known.contains(item.requesterMemberId)) item.requesterMemberId,
    }.difference(_askedAbout);
    if (unknown.isEmpty) return;
    _askedAbout.addAll(unknown);
    ref.invalidate(membersProvider);
  }

  static bool _isOver(BasketStatus? status) =>
      status == BasketStatus.settled || status == BasketStatus.cancelled;
}

final liveBasketProvider = NotifierProvider.autoDispose
    .family<LiveBasketController, LiveBasketState, int>(
      LiveBasketController.new,
    );
