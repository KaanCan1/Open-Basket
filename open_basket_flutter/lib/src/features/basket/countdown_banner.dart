import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/server_clock.dart';
import '../../core/theme.dart';

/// The time left, rendered from the server's clock.
///
/// Rule 1: the client only ever draws `closesAt - serverNow`. It never counts
/// down locally from a number it was handed, because a phone that sleeps for
/// four minutes wakes up with a countdown four minutes ahead of the basket.
/// Every tick recomputes from the corrected clock, so sleeping simply shows
/// the right number on the next frame.
class CountdownBanner extends ConsumerStatefulWidget {
  const CountdownBanner({
    required this.basket,
    this.compact = false,
    this.shopperName = '',
    super.key,
  });

  final Basket basket;

  /// For "Kaan closed it at 18:40" once the basket is no longer open.
  final String shopperName;

  /// One line instead of the full card, for when the keyboard is up and the
  /// list needs the room. The number is still the server's (rule 1).
  final bool compact;

  /// When the banner turns urgent. The server tells everyone at this point
  /// too, so the colour and the notification agree.
  static const lastCall = Duration(minutes: 2);

  @override
  ConsumerState<CountdownBanner> createState() => _CountdownBannerState();
}

class _CountdownBannerState extends ConsumerState<CountdownBanner> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _startTicking();
  }

  @override
  void didUpdateWidget(CountdownBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startTicking();
  }

  /// Only an open basket has a clock worth watching. A frozen one keeps its
  /// `closesAt` as a record of when the run was booked to end, and ticking
  /// that down reads as "still counting" when the list is already final.
  void _startTicking() {
    if (widget.basket.status != BasketStatus.open) {
      _tick?.cancel();
      _tick = null;
      return;
    }
    _tick ??= Timer.periodic(const Duration(seconds: 1), (final _) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final basket = widget.basket;

    final ink = theme.textTheme.bodyLarge!.color!;

    // A basket that is no longer open has no time left to show. Its
    // `closesAt` is a record of when the run was booked to end, and putting
    // that on screen as a number that keeps moving reads as "still counting"
    // when the list is already final.
    if (basket.status != BasketStatus.open) {
      return _Closed(basket: basket, shopperName: widget.shopperName);
    }

    final left = basket.closesAt.difference(
      ref.read(serverClockProvider).now(),
    );
    // Never render a negative countdown. The server closes the basket at
    // zero, and the frozen event may be a moment behind the clock.
    final remaining = left.isNegative ? Duration.zero : left;
    final urgent = remaining <= CountdownBanner.lastCall;
    final label = urgent ? l10n.countdownLastCall : l10n.countdownCheckoutIn;
    if (widget.compact) {
      return Container(
        width: double.infinity,
        color: urgent ? OpenBasketColors.signal : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelSmall!.copyWith(
                  color: urgent ? OpenBasketColors.ink : null,
                ),
              ),
            ),
            Text(
              _format(remaining),
              style: OpenBasketText.countdown(
                urgent ? OpenBasketColors.ink : ink,
              ).copyWith(fontSize: 28),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      // Signal is a fill, never a text colour: at last call the whole block
      // goes lime and the digits stay ink.
      color: urgent ? OpenBasketColors.signal : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall!.copyWith(
              color: urgent ? OpenBasketColors.ink : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _format(remaining),
            style: OpenBasketText.countdown(
              urgent ? OpenBasketColors.ink : ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.liveBasketClosesByItself,
            style: theme.textTheme.labelSmall!.copyWith(
              color: urgent ? OpenBasketColors.ink : null,
            ),
          ),
        ],
      ),
    );
  }

  /// `mm:ss`, and `h:mm:ss` only if someone books an hour.
  static String _format(Duration left) {
    final hours = left.inHours;
    final minutes = left.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = left.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}

/// Screens 22-23: arriving at a basket that is no longer open. It says how it
/// ended and when — the question someone opening the app after a run is
/// actually asking — instead of a bare "frozen".
class _Closed extends StatelessWidget {
  const _Closed({required this.basket, required this.shopperName});

  final Basket basket;
  final String shopperName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ended = (basket.frozenAt ?? basket.closesAt).toLocal();
    final at = DateFormat.Hm().format(ended);
    final ran = (basket.frozenAt ?? basket.closesAt)
        .difference(basket.openedAt)
        .inMinutes;

    final String label;
    final String title;
    final String? note;
    switch (basket.status) {
      case BasketStatus.cancelled:
        label = l10n.countdownCancelled;
        title = l10n.countdownCancelledBy(shopperName);
        note = l10n.countdownCancelledNote;
      case BasketStatus.settled:
        label = l10n.countdownSettled;
        title = basket.closedAutomatically
            ? l10n.countdownClosedItself(at)
            : l10n.countdownClosedBy(shopperName, at);
        note = null;
      case BasketStatus.frozen:
      case BasketStatus.open:
        label = basket.closedAutomatically
            ? l10n.countdownClosedOnTime
            : l10n.countdownFrozen;
        title = basket.closedAutomatically
            ? l10n.countdownClosedItself(at)
            : l10n.countdownClosedBy(shopperName, at);
        note = basket.closedAutomatically
            ? l10n.countdownClosedItselfNote(ran < 1 ? 1 : ran)
            : l10n.countdownListFinal;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.titleMedium),
          if (note != null) ...[
            const SizedBox(height: 2),
            Text(note, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
