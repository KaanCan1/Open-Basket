import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/theme.dart';
import 'basket_controller.dart';

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
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _customMinutes.dispose();
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
          .open(durationMinutes: minutes);
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
        _error = switch (error.error) {
          BasketError.householdAlreadyHasOpenBasket =>
            l10n.openSheetAlreadyOpen,
          // The server's own wording for a duration outside its range is
          // already the sentence a person needs, and it names the bounds.
          BasketError.invalidDuration => error.message,
          _ => l10n.commonSomethingWentWrong,
        };
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

    return Padding(
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
                onTap: () => setState(() => _custom = true),
              ),
            ],
          ),
          if (_custom) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _customMinutes,
              autofocus: true,
              keyboardType: TextInputType.number,
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
                : Text(l10n.openSheetStart),
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
