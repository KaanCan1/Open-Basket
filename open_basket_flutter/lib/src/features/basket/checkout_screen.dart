import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/formatters.dart';
import '../../core/router.dart';
import '../../core/quantity_format.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../stores/stores_controller.dart';
import '../household/household_controller.dart';
import 'basket_controller.dart';
import 'live_basket_controller.dart';
import '../../core/failure_message.dart';

/// Screen 14. The shopper at the till: a price for everything they got, "not
/// available" for everything they did not, the receipt total, and the button
/// that works out who owes what.
///
/// It reads the same live stream as the basket screen — a frozen basket keeps
/// streaming (ADR-017) — so a price typed here reaches every phone in the
/// house as it is saved, and nothing on this screen is its own copy of the
/// truth.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({required this.basketId, super.key});

  final int basketId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _settling = false;

  /// Settling is final (rule 6: a settled run is immutable), and the one
  /// typo that matters — a price typed without its decimal point is a
  /// hundred times too big — only shows in the total. So the total is asked
  /// about once, in words, before anything is written.
  Future<void> _settle() async {
    final l10n = AppLocalizations.of(context);
    final state = ref.read(liveBasketProvider(widget.basketId));
    final basket = state.basket;
    if (basket == null) return;
    final itemSum = state.items
        .where((i) => i.status == ItemStatus.picked && i.priceMinor != null)
        .fold<int>(0, (sum, i) => sum + i.priceMinor!);
    final total = MoneyFormat.format(
      basket.receiptTotalMinor ?? itemSum,
      basket.currencyCode,
    );
    final go = await showCupertinoDialog<bool>(
      context: context,
      builder: (final context) => CupertinoAlertDialog(
        title: Text(l10n.checkoutConfirmTitle(total)),
        content: Text(l10n.checkoutConfirmNote),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.itemMarkCancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.checkoutConfirmYes),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    setState(() => _settling = true);
    try {
      await ref.read(basketControllerProvider).settle(widget.basketId);
      if (!mounted) return;
      context.pushReplacement('${Routes.basket}/${widget.basketId}/settlement');
    } on Exception catch (e) {
      if (!mounted) return;
      _say(failureMessage(AppLocalizations.of(context), e));
    } finally {
      if (mounted) setState(() => _settling = false);
    }
  }

  void _say(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(liveBasketProvider(widget.basketId));
    final members = ref.watch(membersProvider).value ?? const [];
    final basket = state.basket;

    if (basket == null) return const SkeletonScreen();

    final currency = basket.currencyCode;
    final items = state.items;
    final itemSum = items
        .where((i) => i.status == ItemStatus.picked && i.priceMinor != null)
        .fold<int>(0, (sum, i) => sum + i.priceMinor!);
    final unfinished = items
        .where(
          (i) =>
              i.status == ItemStatus.requested ||
              (i.status == ItemStatus.picked && i.priceMinor == null),
        )
        .length;

    // Grouped by who asked, longest-standing member first, the way the house
    // will read the result: "what did I get, and what did it cost". Keyed by
    // id rather than by member, so an item whose requester this phone has not
    // heard of yet still gets a row: hiding it would leave it unpriced and
    // the settle button disabled with nothing on screen to fix.
    final byId = {for (final m in members) m.id!: m};
    final groups = <int, List<BasketItem>>{
      for (final member in members) member.id!: <BasketItem>[],
    };
    for (final item in items) {
      groups.putIfAbsent(item.requesterMemberId, () => []).add(item);
    }
    groups.removeWhere((_, theirs) => theirs.isEmpty);

    final store = (ref.watch(storesProvider).value ?? const <Store>[])
        .where((s) => s.id == basket.storeId)
        .firstOrNull
        ?.name;

    return ObScaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
              children: [
                _LockedCard(
                  basket: basket,
                  itemCount: items.length,
                  storeName: store,
                ),
                const SizedBox(height: 12),
                if (items.isEmpty) ...[
                  Text(l10n.checkoutEmpty, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    l10n.checkoutEmptyNote,
                    style: theme.textTheme.bodySmall,
                  ),
                ] else
                  Text(
                    l10n.checkoutHint,
                    style: OpenBasketText.meta(Ob.of(context).meta),
                  ),
                const SizedBox(height: 8),
                for (final entry in groups.entries) ...[
                  _PersonHeader(
                    member: byId[entry.key],
                    subtotal: entry.value
                        .where(
                          (i) =>
                              i.status == ItemStatus.picked &&
                              i.priceMinor != null,
                        )
                        .fold<int>(0, (sum, i) => sum + i.priceMinor!),
                    currency: currency,
                  ),
                  for (final item in entry.value)
                    _PriceRow(
                      key: ValueKey(item.id),
                      item: item,
                      currency: currency,
                      onError: _say,
                    ),
                ],
              ],
            ),
          ),
          _TotalsPanel(
            basket: basket,
            itemSum: itemSum,
            // The split is across the household as it is now (ADR-036).
            memberCount: ref.watch(activeMembersProvider).value?.length ?? 0,
            unfinished: unfinished,
            settling: _settling,
            onSettle: _settle,
            onError: _say,
          ),
        ],
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard({
    required this.basket,
    required this.itemCount,
    this.storeName,
  });

  final Basket basket;
  final int itemCount;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final closed = basket.frozenAt ?? basket.closesAt;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
      decoration: BoxDecoration(
        color: ob.tonal,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ob.faint),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.lock, size: 13, color: ob.meta),
                    const SizedBox(width: 6),
                    Text(
                      l10n.checkoutLocked,
                      style: OpenBasketText.label(
                        ob.meta,
                      ).copyWith(letterSpacing: 1.1),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  storeName == null
                      ? l10n.checkoutItems(itemCount)
                      : l10n.checkoutStoreItems(storeName!, itemCount),
                  style: OpenBasketText.title(ob.meta, fontSize: 20),
                ),
                Text(
                  l10n.checkoutClosedAt(
                    DateFormat.Hm().format(closed.toLocal()),
                  ),
                  style: OpenBasketText.mono(
                    color: ob.meta,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Tag(l10n.checkoutFrozen),
        ],
      ),
    );
  }
}

class _PersonHeader extends StatelessWidget {
  const _PersonHeader({
    required this.member,
    required this.subtotal,
    required this.currency,
  });

  /// Null while this phone has not heard of the requester yet.
  final HouseholdMember? member;
  final int subtotal;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Row(
        children: [
          if (member != null) ...[
            MemberInitial(member: member!),
            const SizedBox(width: 8),
          ],
          Text(
            member?.displayName ?? AppLocalizations.of(context).checkoutSomeone,
            style: OpenBasketText.body(
              ob.onGround,
            ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: ob.rule)),
          const SizedBox(width: 8),
          Text(
            MoneyFormat.format(subtotal, currency),
            style: OpenBasketText.mono(color: ob.meta, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// The member's square in their tone, for life — the same as on the live
/// basket. Kept as a name the other screens already use.
class MemberInitial extends StatelessWidget {
  const MemberInitial({required this.member, this.size = 22, super.key});

  final HouseholdMember member;
  final double size;

  @override
  Widget build(BuildContext context) => PersonAvatar(
    memberId: member.id!,
    name: member.displayName,
    size: size,
  );
}

/// One item: its name on the left, its price field (or "Undo" when it was not
/// there) on the right. Tapping the name offers "Not available".
class _PriceRow extends ConsumerStatefulWidget {
  const _PriceRow({
    required this.item,
    required this.currency,
    required this.onError,
    super.key,
  });

  final BasketItem item;
  final String currency;
  final void Function(String) onError;

  @override
  ConsumerState<_PriceRow> createState() => _PriceRowState();
}

class _PriceRowState extends ConsumerState<_PriceRow> {
  late final TextEditingController _text;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: _saved);
    _focus.addListener(() {
      if (!_focus.hasFocus) _save();
    });
  }

  @override
  void didUpdateWidget(_PriceRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A price that arrived from the server replaces the field — unless the
    // shopper is typing in it, in which case their keystrokes win until they
    // leave the field.
    if (!_focus.hasFocus && _text.text != _saved) _text.text = _saved;
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _saved {
    final price = widget.item.priceMinor;
    return price == null ? '' : MoneyFormat.plain(price, widget.currency);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final typed = _text.text.trim();
    if (typed == _saved) return;
    if (typed.isEmpty) {
      // Clearing the field puts the item back to "needs a price".
      await _mark(ItemStatus.requested);
      return;
    }
    final minor = MoneyFormat.parse(typed, widget.currency);
    if (minor == null) {
      widget.onError(l10n.checkoutNotAPrice);
      _text.text = _saved;
      return;
    }
    await _mark(ItemStatus.picked, priceMinor: minor);
  }

  Future<void> _mark(ItemStatus status, {int? priceMinor}) async {
    try {
      await ref
          .read(basketControllerProvider)
          .markItem(widget.item.id!, status, priceMinor: priceMinor);
    } on Exception catch (e) {
      if (!mounted) return;
      widget.onError(failureMessage(AppLocalizations.of(context), e));
      _text.text = _saved;
    }
  }

  Future<void> _offerNotAvailable() async {
    final l10n = AppLocalizations.of(context);
    final gone = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (final context) => CupertinoActionSheet(
        title: Text(widget.item.name),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.itemNotAvailable),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.itemMarkCancel),
        ),
      ),
    );
    if (gone == true) await _mark(ItemStatus.unavailable);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ink = theme.textTheme.bodyLarge!.color!;
    final muted = theme.textTheme.bodySmall!.color!;
    final item = widget.item;
    final gone = item.status == ItemStatus.unavailable;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: gone ? null : _offerNotAvailable,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kMinTapTarget),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.name} ${QuantityFormat.label(item.quantity, item.unit)}',
                      style: OpenBasketText.item(gone ? muted : ink).copyWith(
                        fontSize: 15,
                        decoration: gone ? TextDecoration.lineThrough : null,
                        decorationColor: muted,
                      ),
                    ),
                    if (gone)
                      Text(
                        l10n.itemNotAvailable,
                        style: OpenBasketText.meta(
                          muted,
                        ).copyWith(fontWeight: FontWeight.w600),
                      )
                    else if (item.note != null)
                      Text(
                        item.note!,
                        style: OpenBasketText.meta(
                          muted,
                        ).copyWith(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 94,
            height: 44,
            child: gone
                ? GestureDetector(
                    onTap: () => _mark(ItemStatus.requested),
                    child: CustomPaint(
                      painter: DashedRectPainter(
                        color: Ob.of(context).faint,
                        radius: 13,
                      ),
                      child: Center(
                        child: Text(
                          l10n.checkoutUndo,
                          style: OpenBasketText.body(
                            muted,
                          ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  )
                : _MoneyField(
                    controller: _text,
                    focusNode: _focus,
                    currency: widget.currency,
                    onSubmitted: (_) => _focus.unfocus(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// A right-aligned, tabular amount field with the currency symbol in front.
class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.controller,
    required this.focusNode,
    required this.currency,
    required this.onSubmitted,
    this.emphasised = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String currency;
  final ValueChanged<String> onSubmitted;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.textTheme.bodyLarge!.color!;
    final zeroDecimal = MoneyFormat.minorUnitDigits(currency) == 0;

    // A field sized for "54.50" clipped "8990.00" to "8990.0" — and a price
    // with a digit hidden is the one thing this screen must not show. So the
    // amount, symbol included, is measured against the room the field has
    // and shrunk to fit, down to half size for the ten characters it takes.
    return LayoutBuilder(
      builder: (context, constraints) => ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, _) {
          final base = OpenBasketText.money(ink).copyWith(fontSize: 15);
          final symbol = OpenBasketText.money(ink).copyWith(fontSize: 15);
          final painter = TextPainter(
            text: TextSpan(
              children: [
                TextSpan(text: MoneyFormat.symbol(currency), style: symbol),
                TextSpan(text: value.text, style: base),
              ],
            ),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          // Content padding either side, and a little for the cursor.
          final room = constraints.maxWidth - 2 * _padding - 6;
          final scale = painter.width <= room
              ? 1.0
              : (room / painter.width).clamp(0.5, 1.0);
          painter.dispose();
          final size = (base.fontSize ?? 20) * scale;
          return _field(
            theme,
            ink,
            zeroDecimal,
            base.copyWith(fontSize: size),
            symbol.copyWith(fontSize: size),
          );
        },
      ),
    );
  }

  static const _padding = 12.0;

  Widget _field(
    ThemeData theme,
    Color ink,
    bool zeroDecimal,
    TextStyle style,
    TextStyle symbolStyle,
  ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.right,
      style: style,
      keyboardType: TextInputType.numberWithOptions(decimal: !zeroDecimal),
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(10),
      ],
      onSubmitted: onSubmitted,
      // iOS's decimal pad has no return key, so a tap anywhere else is the
      // only way out of the field — and leaving the field is what saves it.
      onTapOutside: (_) => focusNode.unfocus(),
      decoration: InputDecoration(
        isDense: true,
        prefixText: MoneyFormat.symbol(currency),
        prefixStyle: symbolStyle,
        // Priced fields sit on the tonal fill; the one being typed in, and
        // the receipt total, are paper with an ink edge (screen 14).
        fillColor: emphasised || focusNode.hasFocus || controller.text.isEmpty
            ? (theme.brightness == Brightness.dark
                  ? OpenBasketColors.ink
                  : OpenBasketColors.paper)
            : (theme.brightness == Brightness.dark
                  ? const Color(0xFF1C1C1A)
                  : OpenBasketColors.tonal),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _padding,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: emphasised || controller.text.isEmpty
              ? BorderSide(color: ink, width: 1.5)
              : BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A36)
                      : const Color(0xFFC9C9C4),
                  width: 1.5,
                ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: ink, width: 1.5),
        ),
      ),
    );
  }
}

/// The bottom panel: what the items add up to, what the till said, how the
/// difference splits, and the button.
class _TotalsPanel extends ConsumerStatefulWidget {
  const _TotalsPanel({
    required this.basket,
    required this.itemSum,
    required this.memberCount,
    required this.unfinished,
    required this.settling,
    required this.onSettle,
    required this.onError,
  });

  final Basket basket;
  final int itemSum;
  final int memberCount;
  final int unfinished;
  final bool settling;
  final VoidCallback onSettle;
  final void Function(String) onError;

  @override
  ConsumerState<_TotalsPanel> createState() => _TotalsPanelState();
}

class _TotalsPanelState extends ConsumerState<_TotalsPanel> {
  late final TextEditingController _text;
  final _focus = FocusNode();

  String get _saved {
    final total = widget.basket.receiptTotalMinor;
    return total == null
        ? ''
        : MoneyFormat.plain(total, widget.basket.currencyCode);
  }

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: _saved);
    _focus.addListener(() {
      if (!_focus.hasFocus) _save();
      // The panel hides itself while the keyboard is up for someone else's
      // field, so it has to rebuild when its own focus changes.
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(_TotalsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && _text.text != _saved) _text.text = _saved;
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final typed = _text.text.trim();
    if (typed == _saved || typed.isEmpty) {
      _text.text = _saved;
      return;
    }
    final minor = MoneyFormat.parse(typed, widget.basket.currencyCode);
    if (minor == null || minor == 0) {
      widget.onError(l10n.checkoutNotAPrice);
      _text.text = _saved;
      return;
    }
    try {
      await ref
          .read(basketControllerProvider)
          .setReceiptTotal(widget.basket.id!, minor);
    } on Exception catch (e) {
      if (!mounted) return;
      widget.onError(failureMessage(l10n, e));
      _text.text = _saved;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ink = theme.textTheme.bodyLarge!.color!;
    final currency = widget.basket.currencyCode;
    final receipt = widget.basket.receiptTotalMinor;
    final gap = receipt == null ? 0 : receipt - widget.itemSum;
    final count = widget.memberCount;
    // With the keyboard up for an item's price, the panel would ride up on it
    // and crush the list to a row or two — found on a phone, where the next
    // item to price was hidden behind the totals. It steps aside instead, and
    // stays when the keyboard is up for its own receipt field.
    if (MediaQuery.viewInsetsOf(context).bottom > 0 && !_focus.hasFocus) {
      return const SizedBox.shrink();
    }

    // Display only. The server works out the real split (rule 6); this is
    // the same truncating division, so the two agree on the members' share.
    final each = count == 0 ? 0 : gap ~/ count;

    final ob = Ob.of(context);
    return Glass(
      shadow: true,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.checkoutItemsAddUp,
                      style: OpenBasketText.meta(ob.meta),
                    ),
                  ),
                  Text(
                    MoneyFormat.format(widget.itemSum, currency),
                    style: OpenBasketText.money(ink).copyWith(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.checkoutReceiptTotal,
                      style: OpenBasketText.meta(ob.meta),
                    ),
                  ),
                  SizedBox(
                    width: 128,
                    height: 44,
                    child: _MoneyField(
                      controller: _text,
                      focusNode: _focus,
                      currency: currency,
                      emphasised: true,
                      onSubmitted: (_) => _focus.unfocus(),
                    ),
                  ),
                ],
              ),
              if (gap != 0 && count > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
                  decoration: BoxDecoration(
                    color: ob.dark
                        ? const Color(0xFF2C2C29)
                        : OpenBasketColors.ink,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          CupertinoIcons.exclamationmark_circle,
                          size: 16,
                          color: OpenBasketColors.signal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          gap > 0
                              ? l10n.checkoutGapMore(
                                  MoneyFormat.format(gap, currency),
                                  count,
                                  MoneyFormat.format(each, currency),
                                )
                              : l10n.checkoutGapLess(
                                  MoneyFormat.format(-gap, currency),
                                  count,
                                  MoneyFormat.format(-each, currency),
                                ),
                          style: OpenBasketText.meta(
                            OpenBasketColors.paper,
                          ).copyWith(fontSize: 12.5, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (widget.unfinished > 0) ...[
                Text(
                  l10n.checkoutUnfinished(widget.unfinished),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                // Rule 6 and ADR-029: nothing counts as free by accident. The
                // server refuses too; this keeps the refusal from being the
                // way the shopper finds out.
                onPressed: widget.unfinished > 0 || widget.settling
                    ? null
                    : widget.onSettle,
                child: widget.settling
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.checkoutSettle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
