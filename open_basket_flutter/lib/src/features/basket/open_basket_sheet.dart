import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/eta.dart';
import '../../core/location.dart';
import '../../core/router.dart';
import '../../core/server_clock.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../stores/stores_controller.dart';
import 'basket_controller.dart';
import '../../core/failure_message.dart';

/// Screen 06, as a sheet. How long the run is booked for.
///
/// Quick picks rather than a picker: the shopper is already walking, and
/// "about ten minutes" is the real answer to the real question. The custom
/// field is there for the weekly shop.
class OpenBasketSheet extends ConsumerStatefulWidget {
  const OpenBasketSheet({super.key});

  static const quickPicks = [5, 10, 15, 20];

  /// Returns the basket that was opened, or null if the sheet was dismissed.
  static Future<Basket?> show(BuildContext context) {
    return showGlassSheet<Basket>(
      context: context,
      builder: (final _) => const OpenBasketSheet(),
    );
  }

  @override
  ConsumerState<OpenBasketSheet> createState() => _OpenBasketSheetState();
}

class _OpenBasketSheetState extends ConsumerState<OpenBasketSheet> {
  int _minutes = 10;
  bool _custom = false;
  final _customMinutes = TextEditingController();

  /// Focused only when the shopper taps *Custom*. An estimate that lands on a
  /// custom number fills the field too, and a keyboard jumping up over the
  /// open button because a store was tapped is the wrong answer.
  final _customFocus = FocusNode();
  bool _busy = false;
  String? _error;

  /// Screen 06's store row. Picking a store with a pinned location reads this
  /// phone's position once and suggests a duration (ADR-002); the position is
  /// used for that one sum and dropped.
  Store? _store;
  bool _estimating = false;
  int? _estimate;

  Future<void> _pickStore(Store store) async {
    if (_store?.id == store.id) {
      setState(() {
        _store = null;
        _estimate = null;
      });
      return;
    }
    setState(() {
      _store = store;
      _estimate = null;
      _estimating = store.lat != null && store.lng != null;
    });
    if (!_estimating) return;

    final here = await LocationOnce.read();
    if (!mounted || _store?.id != store.id) return;
    final minutes = here == null
        ? null
        : Eta.suggestMinutes(
            fromLat: here.lat,
            fromLng: here.lng,
            storeLat: store.lat!,
            storeLng: store.lng!,
          );
    setState(() {
      _estimating = false;
      _estimate = minutes;
      // The suggestion becomes the selection, so "Open for 17 minutes" is one
      // tap — and every pick stays a tap away if the shopper knows better.
      if (minutes != null) _select(minutes);
    });
  }

  void _select(int minutes) {
    if (OpenBasketSheet.quickPicks.contains(minutes)) {
      _custom = false;
      _minutes = minutes;
    } else {
      _custom = true;
      _customMinutes.text = '$minutes';
    }
  }

  int? get _chosenMinutes {
    if (!_custom) return _minutes;
    final typed = int.tryParse(_customMinutes.text.trim());
    return typed == null || typed <= 0 ? null : typed;
  }

  @override
  void dispose() {
    _customMinutes.dispose();
    _customFocus.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final l10n = AppLocalizations.of(context);
    final minutes = _custom
        ? int.tryParse(_customMinutes.text.trim()) ?? 0
        : _minutes;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final basket = await ref
          .read(basketControllerProvider)
          .open(durationMinutes: minutes, storeId: _store?.id);
      if (!mounted) return;
      Navigator.of(context).pop(basket);
    } on OpenBasketException catch (error) {
      if (!mounted) return;
      // Screen 24: not an error. Someone else got there first, so hand back
      // their run and let the caller take this person into it, add bar and
      // all. Only if that fails does the old sentence appear.
      if (error.error == BasketError.householdAlreadyHasOpenBasket) {
        final running = await _runningBasket();
        if (!mounted) return;
        if (running != null) {
          Navigator.of(context).pop(running);
          return;
        }
      }
      setState(() {
        _error = failureMessage(l10n, error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.commonOffline);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Basket?> _runningBasket() async {
    try {
      ref.invalidate(activeBasketProvider);
      final running = await ref.read(activeBasketProvider.future);
      return running?.status == BasketStatus.open ? running : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final chosen = _chosenMinutes;
    final closes = chosen == null
        ? null
        : DateFormat.Hm().format(
            ref
                .read(serverClockProvider)
                .now()
                .add(Duration(minutes: chosen))
                .toLocal(),
          );

    // Scrollable: with the store row, the estimate and the custom field's
    // keyboard all on screen, a fixed column ran off the bottom of a phone.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitle(
            l10n.openSheetTitle,
            subtitle: l10n.openSheetBlurb,
            fontSize: 27,
          ),
          const SizedBox(height: 22),
          SectionLabel(
            l10n.openSheetStore,
            action: l10n.openSheetAddStore,
            onAction: () => context.push(Routes.stores),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final store in ref.watch(storesProvider).value ?? <Store>[])
                _Pick(
                  label: store.name,
                  selected: _store?.id == store.id,
                  onTap: () => _pickStore(store),
                ),
              _AddPick(onTap: () => context.push(Routes.stores)),
            ],
          ),
          const SizedBox(height: 22),
          SectionLabel(
            l10n.openSheetHowLong,
            action: l10n.openSheetCustom,
            onAction: () {
              setState(() => _custom = true);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _customFocus.requestFocus(),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final minutes in OpenBasketSheet.quickPicks) ...[
                if (minutes != OpenBasketSheet.quickPicks.first)
                  const SizedBox(width: 8),
                Expanded(
                  child: _MinutesTile(
                    minutes: minutes,
                    selected: !_custom && _minutes == minutes,
                    onTap: () => setState(() {
                      _custom = false;
                      _minutes = minutes;
                      _customFocus.unfocus();
                    }),
                  ),
                ),
              ],
            ],
          ),
          if (_custom) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customMinutes,
              focusNode: _customFocus,
              // The number pad has no return key and covered the Open
              // button; a tap anywhere else is the way out.
              onTapOutside: (_) => _customFocus.unfocus(),
              keyboardType: TextInputType.number,
              style: OpenBasketText.mono(color: ob.onGround, fontSize: 19),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '30',
                suffixText: l10n.openSheetMinUnit,
              ),
            ),
          ],
          if (_store != null) ...[
            const SizedBox(height: 10),
            _Estimate(
              store: _store!,
              estimating: _estimating,
              minutes: _estimate,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: OpenBasketText.meta(Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 22),
          PrimaryButton(
            glow: true,
            busy: _busy,
            onPressed: chosen == null ? null : _open,
            label: chosen == null
                ? l10n.openSheetStart
                : l10n.openSheetOpenFor(chosen),
          ),
          if (closes != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.openSheetClosesAt(closes),
              textAlign: TextAlign.center,
              style: OpenBasketText.meta(ob.meta).copyWith(fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// A store chip: tonal, ink when picked.
class _Pick extends StatelessWidget {
  const _Pick({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: kMinTapTarget,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? ob.onGround : ob.tonal,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            style: OpenBasketText.body(
              selected ? ob.ground : ob.onGround,
            ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

/// The dashed + after the stores.
class _AddPick extends StatelessWidget {
  const _AddPick({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedRectPainter(color: ob.faint, radius: 14),
        child: SizedBox(
          width: kMinTapTarget,
          height: kMinTapTarget,
          child: Icon(CupertinoIcons.add, size: 18, color: ob.onGround),
        ),
      ),
    );
  }
}

/// "15 / min" — one of the four quick picks, ink when chosen.
class _MinutesTile extends StatelessWidget {
  const _MinutesTile({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: selected ? ob.onGround : ob.tonal,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minutes',
              style: OpenBasketText.mono(
                color: selected ? ob.ground : ob.onGround,
                fontSize: 19,
              ),
            ),
            Text(
              l10n.openSheetMinUnit,
              style: OpenBasketText.meta(
                selected
                    ? (ob.dark
                          ? OpenBasketColors.meta
                          : OpenBasketColors.metaDark)
                    : ob.meta,
              ).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Estimated 12 min from your distance to Migros." A quiet panel, never an
/// error: without a pinned location or a position it says so and the picks
/// above carry on as before.
class _Estimate extends StatelessWidget {
  const _Estimate({
    required this.store,
    required this.estimating,
    required this.minutes,
  });

  final Store store;
  final bool estimating;
  final int? minutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final style = OpenBasketText.meta(ob.meta).copyWith(height: 1.45);

    final Widget text;
    if (estimating) {
      text = Text(l10n.openSheetEstimating(store.name), style: style);
    } else if (minutes != null) {
      final whole = l10n.openSheetEstimateLine(minutes!, store.name);
      final bold = l10n.openSheetMinutes(minutes!);
      final at = whole.indexOf(bold);
      text = at < 0
          ? Text(whole, style: style)
          : Text.rich(
              TextSpan(
                style: style,
                children: [
                  TextSpan(text: whole.substring(0, at)),
                  TextSpan(
                    text: bold,
                    style: TextStyle(
                      color: ob.onGround,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: whole.substring(at + bold.length)),
                ],
              ),
            );
    } else {
      text = Text(l10n.openSheetNoEstimate(store.name), style: style);
    }

    return TonalCard(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.clock, size: 16, color: ob.onGround),
          const SizedBox(width: 11),
          Expanded(child: text),
        ],
      ),
    );
  }
}
