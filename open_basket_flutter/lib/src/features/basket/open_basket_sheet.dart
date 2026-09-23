import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/eta.dart';
import '../../core/location.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
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
    return showModalBottomSheet<Basket>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    final theme = Theme.of(context);

    // Scrollable: with the store row, the estimate and the custom field's
    // keyboard all on screen, a fixed column ran off the bottom of a phone.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.openSheetTitle, style: theme.textTheme.displayLarge),
          const SizedBox(height: 8),
          Text(l10n.openSheetBlurb, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(l10n.openSheetStore, style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
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
              _Pick(
                label: l10n.openSheetAddStore,
                selected: false,
                onTap: () => context.push(Routes.stores),
              ),
            ],
          ),
          if (_store != null) ...[
            const SizedBox(height: 12),
            _Estimate(
              store: _store!,
              estimating: _estimating,
              minutes: _estimate,
            ),
          ],
          const SizedBox(height: 20),
          Text(l10n.openSheetHowLong, style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final minutes in OpenBasketSheet.quickPicks)
                _Pick(
                  label: l10n.openSheetMinutes(minutes),
                  selected: !_custom && _minutes == minutes,
                  onTap: () => setState(() {
                    _custom = false;
                    _minutes = minutes;
                  }),
                ),
              _Pick(
                label: l10n.openSheetCustom,
                selected: _custom,
                onTap: () {
                  setState(() => _custom = true);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _customFocus.requestFocus(),
                  );
                },
              ),
            ],
          ),
          if (_custom) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _customMinutes,
              focusNode: _customFocus,
              // The number pad has no return key and covered the Open
              // button; a tap anywhere else is the way out.
              onTapOutside: (_) => _customFocus.unfocus(),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: '30'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: OpenBasketText.meta(theme.colorScheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _open,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _chosenMinutes == null
                        ? l10n.openSheetStart
                        : l10n.openSheetOpenFor(_chosenMinutes!),
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    final ink = theme.textTheme.bodyLarge!.color!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Vertical padding rather than a minHeight plus an alignment: a
        // Container given an alignment expands to fill the constraints it is
        // handed, and inside a stretched Column that made every pick the
        // full width of the sheet instead of a chip. The padding keeps the
        // 44pt tap target without asking for any width.
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          // Selected is a fill, so Signal never has to carry text.
          color: selected
              ? OpenBasketColors.signal
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: selected ? OpenBasketColors.ink : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: OpenBasketText.item(selected ? OpenBasketColors.ink : ink),
        ),
      ),
    );
  }
}

/// "Estimated 12 min — from your distance to Migros." A quiet panel, never an
/// error: without a pinned location or a position it says so and the picks
/// below carry on as before.
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
    final theme = Theme.of(context);

    final String title;
    final String? note;
    if (estimating) {
      title = l10n.openSheetEstimating(store.name);
      note = null;
    } else if (minutes != null) {
      title = l10n.openSheetEstimated(minutes!);
      note = l10n.openSheetEstimatedNote(store.name);
    } else {
      title = l10n.openSheetNoEstimate(store.name);
      note = null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
