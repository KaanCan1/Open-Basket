import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/theme.dart';
import 'basket_controller.dart';
import 'live_basket_controller.dart';
import 'live_basket_state.dart';
import '../../core/failure_message.dart';

/// The bar at the bottom of a live basket.
///
/// Optimism is deliberately absent: the row appears when the server has
/// accepted it and the stream has echoed it back. A basket where your item
/// shows on your phone and nowhere else is worse than one that takes half a
/// second, because the whole promise of the product is that everyone is
/// looking at the same list.
///
/// The one exception is being offline (ADR-011): then the item is queued on
/// this phone, shown as a dashed row that says so, and sent on reconnect —
/// never passed off as being on everyone's list.
class AddItemBar extends ConsumerStatefulWidget {
  const AddItemBar({required this.basketId, super.key});

  final int basketId;

  @override
  ConsumerState<AddItemBar> createState() => _AddItemBarState();
}

class _AddItemBarState extends ConsumerState<AddItemBar> {
  final _name = TextEditingController();
  final _note = TextEditingController();
  final _nameFocus = FocusNode();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _add([String? suggested]) async {
    final l10n = AppLocalizations.of(context);
    final name = (suggested ?? _name.text).trim();
    if (name.isEmpty) return;

    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final note = suggested == null ? _note.text.trim() : '';
      await ref
          .read(liveBasketProvider(widget.basketId).notifier)
          .add(name, note: note.isEmpty ? null : note);
      if (!mounted) return;
      if (suggested != null) return;
      _name.clear();
      _note.clear();
      // Keep the keyboard up: a shopping list is typed in bursts, and making
      // someone tap back into the field between "milk" and "eggs" is the
      // difference between adding three things and adding one.
      _nameFocus.requestFocus();
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _error = failureMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// The caller's usual items that are not on this run yet, so a chip never
  /// offers something already there. Hidden while typing: the field is the
  /// thing being used then.
  List<String> _suggestions() {
    if (_name.text.isNotEmpty || MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const [];
    }
    final usual = ref.watch(suggestionsProvider).value ?? const <String>[];
    final state = ref.watch(liveBasketProvider(widget.basketId));
    final present = {
      for (final i in state.items) i.name.trim().toLowerCase(),
      for (final q in state.queued) q.name.trim().toLowerCase(),
    };
    return [
      for (final name in usual)
        if (!present.contains(name.trim().toLowerCase())) name,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final offline =
        ref.watch(
          liveBasketProvider(widget.basketId).select((s) => s.connection),
        ) ==
        LiveConnection.reconnecting;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_suggestions().isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.liveBasketUsually,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final name in _suggestions())
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(name),
                          onPressed: _sending ? null : () => _add(name),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          side: BorderSide(color: theme.dividerColor),
                          labelStyle: OpenBasketText.body(
                            theme.textTheme.bodyLarge!.color!,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (offline && _error == null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.liveBasketOfflineHint,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (_error != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: OpenBasketText.meta(theme.colorScheme.error),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _name,
                        focusNode: _nameFocus,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: l10n.liveBasketAddHint,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sending ? null : _add(),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _note,
                        decoration: InputDecoration(
                          hintText: l10n.liveBasketNoteHint,
                          isDense: true,
                        ),
                        style: OpenBasketText.meta(
                          theme.textTheme.bodySmall!.color!,
                        ),
                        onSubmitted: (_) => _sending ? null : _add(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 84,
                  child: FilledButton(
                    onPressed: _sending ? null : _add,
                    child: _sending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.liveBasketAdd),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
