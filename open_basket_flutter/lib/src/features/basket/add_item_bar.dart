import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/quantity_format.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
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

  /// How much of the typed item, and in what (screen 09's stepper). Back to
  /// one piece after every add: the next thing is rarely a kilo too.
  int _quantity = 1;
  ItemUnit _unit = ItemUnit.piece;

  /// The note row stays folded until someone wants it: most items are just
  /// a name, and an always-open second field doubled the bar's height.
  bool _noteOpen = false;

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
          .add(
            name,
            note: note.isEmpty ? null : note,
            quantity: suggested == null && _quantity > 1 ? _quantity : null,
            unit: suggested == null && _unit != ItemUnit.piece ? _unit : null,
          );
      if (!mounted) return;
      if (suggested != null) return;
      _name.clear();
      _note.clear();
      setState(() {
        _quantity = 1;
        _unit = ItemUnit.piece;
        _noteOpen = false;
      });
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

  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  void _step(int direction) {
    final step = QuantityFormat.step(_unit);
    setState(() {
      _quantity = (_quantity + direction * step).clamp(
        step,
        QuantityFormat.max(_unit),
      );
    });
  }

  /// Pieces, kilos, grams, litres, millilitres or packs. A new unit starts
  /// where people usually start with it: 500 g, 1 kg.
  Future<void> _pickUnit() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showCupertinoModalPopup<ItemUnit>(
      context: context,
      builder: (final context) => CupertinoActionSheet(
        title: Text(l10n.liveBasketUnitTitle),
        actions: [
          for (final unit in ItemUnit.values)
            CupertinoActionSheetAction(
              isDefaultAction: unit == _unit,
              onPressed: () => Navigator.of(context).pop(unit),
              child: Text(_unitLabel(l10n, unit)),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.itemMarkCancel),
        ),
      ),
    );
    if (picked == null || picked == _unit || !mounted) return;
    setState(() {
      _unit = picked;
      _quantity = QuantityFormat.start(picked);
    });
  }

  static String _unitLabel(AppLocalizations l10n, ItemUnit unit) =>
      switch (unit) {
        ItemUnit.piece => l10n.unitPieces,
        ItemUnit.kg => l10n.unitKilograms,
        ItemUnit.g => l10n.unitGrams,
        ItemUnit.l => l10n.unitLitres,
        ItemUnit.ml => l10n.unitMillilitres,
        ItemUnit.pack => l10n.unitPacks,
      };

  /// A quick note appended to whatever is already there: "any brand, only
  /// if fresh". Tapping one twice does not write it twice.
  void _addNote(String phrase) {
    final current = _note.text.trim();
    if (current.toLowerCase().contains(phrase.toLowerCase())) return;
    _note.text = current.isEmpty ? phrase : '$current, $phrase';
    _note.selection = TextSelection.collapsed(offset: _note.text.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final offline =
        ref.watch(
          liveBasketProvider(widget.basketId).select((s) => s.connection),
        ) ==
        LiveConnection.reconnecting;
    final fieldFill = ob.dark
        ? const Color(0xE61A1A17)
        : OpenBasketColors.paper.withValues(alpha: 0.9);

    // Sits inside the screen's frosted bar (GlassBar), so it draws no
    // background of its own.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          Text(
            _error!,
            style: OpenBasketText.meta(Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
        // One tap region for both fields and the Add button: a tap anywhere
        // else puts the keyboard away (it covered half the list and nothing
        // dismissed it), while tapping Add or moving to the note keeps it up.
        TextFieldTapRegion(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _name,
                      onTapOutside: (_) => _dismissKeyboard(),
                      focusNode: _nameFocus,
                      textCapitalization: TextCapitalization.sentences,
                      style: OpenBasketText.body(
                        ob.onGround,
                      ).copyWith(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: l10n.liveBasketAddHint,
                        hintStyle: OpenBasketText.body(
                          const Color(0xFF8E8E88),
                        ).copyWith(fontSize: 15),
                        fillColor: fieldFill,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: ob.onGround,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: ob.onGround,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _sending ? null : _add(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Stepper(
                    label: QuantityFormat.label(_quantity, _unit),
                    semantics: l10n.liveBasketQuantityLabel(
                      QuantityFormat.label(_quantity, _unit),
                    ),
                    canLess: _quantity > QuantityFormat.step(_unit),
                    canMore: _quantity < QuantityFormat.max(_unit),
                    onLess: () => _step(-1),
                    onMore: () => _step(1),
                    onUnit: _pickUnit,
                  ),
                  const SizedBox(width: 8),
                  SizedBox.square(
                    dimension: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size.square(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _sending ? null : _add,
                      child: _sending
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Semantics(
                              label: l10n.liveBasketAdd,
                              child: const Icon(
                                CupertinoIcons.arrow_right,
                                size: 20,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              if (_noteOpen) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _note,
                  autofocus: true,
                  onTapOutside: (_) => _dismissKeyboard(),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: l10n.liveBasketNoteHint,
                    isDense: true,
                    fillColor: fieldFill,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: ob.faint),
                    ),
                  ),
                  style: OpenBasketText.body(ob.onGround),
                  onSubmitted: (_) => _sending ? null : _add(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final phrase in [
                        l10n.noteAnyBrand,
                        l10n.noteOnlyIfFresh,
                        l10n.noteCheapest,
                        l10n.noteOrganic,
                        l10n.noteBigPack,
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _PhraseChip(
                            label: phrase,
                            onTap: () => _addNote(phrase),
                          ),
                        ),
                    ],
                  ),
                ),
              ] else
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _noteOpen = true),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                    child: Row(
                      children: [
                        Icon(
                          offline
                              ? CupertinoIcons.wifi_slash
                              : CupertinoIcons.text_alignleft,
                          size: 15,
                          color: const Color(0xFF8E8E88),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            offline
                                ? l10n.liveBasketOfflineHint
                                : l10n.liveBasketAddNote,
                            style: OpenBasketText.meta(ob.meta),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhraseChip extends StatelessWidget {
  const _PhraseChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ob.tonal,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: OpenBasketText.meta(
            ob.onGround,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// "YOU USUALLY ASK FOR  + Whole milk  + Bread": the caller's usual items
/// that are not on this run yet, one tap each (screens 10, 24).
class UsualChips extends ConsumerStatefulWidget {
  const UsualChips({required this.basketId, this.note, super.key});

  final int basketId;

  /// "From your last four runs at Migros."
  final String? note;

  @override
  ConsumerState<UsualChips> createState() => _UsualChipsState();
}

class _UsualChipsState extends ConsumerState<UsualChips> {
  final _sending = <String>{};

  Future<void> _add(String name) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending.add(name));
    try {
      await ref.read(liveBasketProvider(widget.basketId).notifier).add(name);
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    } finally {
      if (mounted) setState(() => _sending.remove(name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final usual = ref.watch(suggestionsProvider).value ?? const <String>[];
    final state = ref.watch(liveBasketProvider(widget.basketId));
    final present = {
      for (final i in state.items) i.name.trim().toLowerCase(),
      for (final q in state.queued) q.name.trim().toLowerCase(),
    };
    final names = [
      for (final name in usual)
        if (!present.contains(name.trim().toLowerCase())) name,
    ];
    if (names.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l10n.liveBasketUsually),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in names)
              GestureDetector(
                onTap: _sending.contains(name) ? null : () => _add(name),
                child: Opacity(
                  opacity: _sending.contains(name) ? 0.5 : 1,
                  child: Glass(
                    radius: 14,
                    shadow: false,
                    child: Container(
                      height: kMinTapTarget,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.add,
                            size: 14,
                            color: ob.onGround,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: OpenBasketText.body(ob.onGround).copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (widget.note != null) ...[
          const SizedBox(height: 10),
          Text(widget.note!, style: OpenBasketText.meta(ob.meta)),
        ],
      ],
    );
  }
}

/// Screen 09's "− 1 +", with the unit inside: tapping the amount picks what
/// it counts. Each half is a full 44-point target.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.semantics,
    required this.canLess,
    required this.canMore,
    required this.onLess,
    required this.onMore,
    required this.onUnit,
  });

  final String label;
  final String semantics;
  final bool canLess;
  final bool canMore;
  final VoidCallback onLess;
  final VoidCallback onMore;
  final VoidCallback onUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.textTheme.bodyLarge!.color!;
    final muted = theme.textTheme.bodySmall!.color!;

    Widget button(IconData icon, bool enabled, VoidCallback onTap) =>
        SizedBox.square(
          dimension: 44,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: enabled ? onTap : null,
            icon: Icon(
              icon,
              size: 16,
              color: enabled ? muted : muted.withValues(alpha: 0.4),
            ),
          ),
        );

    final dark = theme.brightness == Brightness.dark;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: dark
            ? const Color(0xE61A1A17)
            : OpenBasketColors.paper.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? const Color(0xFF3A3A36) : const Color(0xFFD8D8D4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(CupertinoIcons.minus, canLess, onLess),
          Semantics(
            button: true,
            label: semantics,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onUnit,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 28, minHeight: 44),
                child: Center(
                  child: Text(
                    label,
                    style: OpenBasketText.money(
                      ink,
                    ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
          button(CupertinoIcons.plus, canMore, onMore),
        ],
      ),
    );
  }
}
