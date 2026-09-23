import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/client_provider.dart';
import '../../core/server_clock.dart';
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
  int _attempt = 0;

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
    _connect();
    return const LiveBasketState.connecting();
  }

  void _stop() {
    _retry?.cancel();
    _retry = null;
    _subscription?.cancel();
    _subscription = null;
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
      BasketEventType.snapshot => LiveBasketState(
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

    _refreshMembersIfSomeoneIsNew();

    // The home screen reads the basket through its own provider, fetched
    // once. Without this it kept saying "a basket is open" after the stream
    // had reported the basket frozen — found by letting a basket close itself
    // in the background and then going back.
    if (event.type != BasketEventType.itemAdded &&
        event.type != BasketEventType.itemUpdated &&
        event.type != BasketEventType.itemRemoved) {
      ref.invalidate(activeBasketProvider);
      ref.invalidate(lastSettledRunProvider);
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
