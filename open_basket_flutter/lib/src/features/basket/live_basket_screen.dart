import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../household/household_controller.dart';
import 'add_item_bar.dart';
import 'basket_controller.dart';
import 'countdown_banner.dart';
import 'live_basket_controller.dart';
import 'live_basket_state.dart';

/// Screens 08 and 09. The live basket, for the shopper and for everyone else.
///
/// The two roles are the same screen: the list, the countdown and the item
/// rows are identical, and only the actions at the bottom differ. Splitting
/// them would mean two places to fix every layout problem for a difference
/// that is three buttons.
class LiveBasketScreen extends ConsumerWidget {
  const LiveBasketScreen({required this.basketId, super.key});

  final int basketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(liveBasketProvider(basketId));
    final me = ref.watch(myMembershipProvider).value;
    final members = ref.watch(membersProvider).value ?? const [];

    final basket = state.basket;
    if (basket == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // With the keyboard up there is room for the add bar and a few rows, not
    // for the full countdown card, the strip and the shopper's buttons too:
    // together they overflowed the screen and left the list no height at all.
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isShopper = basket.shopperMemberId == me?.id;
    final isOpen = basket.status == BasketStatus.open;
    final isFrozen = basket.status == BasketStatus.frozen;
    final isSettled = basket.status == BasketStatus.settled;
    final shopperName = _nameFor(members, basket.shopperMemberId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.queued.isEmpty
              ? l10n.liveBasketItems(state.items.length)
              : '${l10n.liveBasketItems(state.items.length)} · '
                    '${l10n.liveBasketQueuedCount(state.queued.length)}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
      body: Column(
        children: [
          CountdownBanner(basket: basket, compact: typing),
          // Screen 25: the countdown stays at full strength while offline,
          // because it is the server's clock and not this phone's; the strip
          // says why the list may be behind.
          if (state.connection == LiveConnection.reconnecting)
            _Strip(
              title: l10n.liveBasketReconnecting,
              note: typing ? null : l10n.liveBasketReconnectingNote,
              meta: state.lastSyncedAt == null
                  ? null
                  : l10n.liveBasketLastSynced(
                      DateFormat.Hm().format(state.lastSyncedAt!),
                    ),
            )
          else if (state.report != null)
            _ReportStrip(report: state.report!),
          Expanded(
            child: state.items.isEmpty && state.queued.isEmpty
                ? _Empty(isOpen: isOpen)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: state.items.length + state.queued.length,
                    itemBuilder: (final context, final index) {
                      if (index >= state.items.length) {
                        return _QueuedRow(
                          item: state.queued[index - state.items.length],
                        );
                      }
                      final item = state.items[index];
                      return _ItemRow(
                        item: item,
                        requester: _nameFor(members, item.requesterMemberId),
                        shopper: shopperName,
                        // ADR-005: the shopper ticks things off while walking
                        // the aisles. Prices wait for the checkout screen.
                        onTap: isOpen && isShopper
                            ? () => _markItem(context, ref, item)
                            : null,
                        // Rule 3 in its narrowest form: your own item, and
                        // only while the list is still open.
                        onRemove: isOpen && item.requesterMemberId == me?.id
                            ? () => ref
                                  .read(basketControllerProvider)
                                  .removeItem(item.id!)
                            : null,
                      );
                    },
                  ),
          ),
          if (isSettled)
            _BottomAction(
              label: l10n.liveBasketSeeSettlement,
              onPressed: () =>
                  context.push('${Routes.basket}/$basketId/settlement'),
            )
          else if (state.connection == LiveConnection.over)
            _Closed(onBack: () => context.pop())
          else if (isOpen) ...[
            if (isShopper && !typing) _ShopperActions(basket: basket),
            AddItemBar(basketId: basketId),
          ] else if (isFrozen && isShopper)
            _BottomAction(
              label: l10n.liveBasketEnterPrices,
              onPressed: () =>
                  context.push('${Routes.basket}/$basketId/checkout'),
            )
          else if (isFrozen)
            _Waiting(shopper: shopperName),
        ],
      ),
    );
  }

  /// An iOS action sheet rather than three buttons on every row: the row
  /// stays readable, and the thumb that tapped it is already where the sheet
  /// appears.
  static Future<void> _markItem(
    BuildContext context,
    WidgetRef ref,
    BasketItem item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showCupertinoModalPopup<ItemStatus>(
      context: context,
      builder: (final context) => CupertinoActionSheet(
        title: Text(item.name),
        actions: [
          if (item.status != ItemStatus.picked)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ItemStatus.picked),
              child: Text(l10n.itemGotIt),
            ),
          if (item.status != ItemStatus.unavailable)
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(context).pop(ItemStatus.unavailable),
              child: Text(l10n.itemNotAvailable),
            ),
          if (item.status != ItemStatus.requested)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ItemStatus.requested),
              child: Text(l10n.itemMarkBackOnList),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.itemMarkCancel),
        ),
      ),
    );
    if (choice == null) return;
    try {
      await ref.read(basketControllerProvider).markItem(item.id!, choice);
    } on Exception {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.checkoutDidNotSave)));
    }
  }

  static String _nameFor(List<HouseholdMember> members, int memberId) {
    for (final member in members) {
      if (member.id == memberId) return member.displayName;
    }
    return '';
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.requester,
    required this.shopper,
    required this.onTap,
    required this.onRemove,
  });

  final BasketItem item;
  final String requester;
  final String shopper;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = MemberTones.forMember(
      item.requesterMemberId,
      theme.brightness,
    );

    final l10n = AppLocalizations.of(context);
    final muted = theme.textTheme.bodySmall!.color!;
    final ink = theme.textTheme.bodyLarge!.color!;
    final gone = item.status == ItemStatus.unavailable;
    final got = item.status == ItemStatus.picked;

    final row = Container(
      constraints: const BoxConstraints(minHeight: kMinTapTarget),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.quantity > 1
                      ? '${item.name}  ×${item.quantity}'
                      : item.name,
                  style: gone
                      ? OpenBasketText.item(
                          muted,
                        ).copyWith(decoration: TextDecoration.lineThrough)
                      : OpenBasketText.item(ink),
                ),
                if (gone || got) ...[
                  const SizedBox(height: 2),
                  Text(
                    gone ? l10n.itemNotAvailable : l10n.itemGotBy(shopper),
                    style: OpenBasketText.meta(muted),
                  ),
                ],
                if (item.note != null && !gone) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.note!,
                    style: OpenBasketText.meta(
                      theme.textTheme.bodySmall!.color!,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // The tick is ink, not signal: got items are settled business, and
          // the signal belongs to time. A 32px glyph in a 44px box.
          if (got)
            SizedBox.square(
              dimension: kMinTapTarget,
              child: Icon(CupertinoIcons.checkmark_alt, size: 24, color: ink),
            ),
          // The person chip, in that member's tone for life. People learn
          // their colour, which is why it never changes.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: tone)),
            child: Text(
              requester.toUpperCase(),
              style: theme.textTheme.labelSmall!.copyWith(color: tone),
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              tooltip: AppLocalizations.of(context).liveBasketRemove,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

class _ShopperActions extends ConsumerWidget {
  const _ShopperActions({required this.basket});

  final Basket basket;

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(l10n.liveBasketCancelConfirm),
        content: Text(l10n.liveBasketCancelConfirmNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.liveBasketCancelKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.liveBasketCancelYes),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(basketControllerProvider).cancel(basket.id!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(basketControllerProvider);
    final extended = basket.extendCount >= 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: extended ? null : () => controller.extend(basket.id!),
              child: Text(
                extended ? l10n.liveBasketExtendUsed : l10n.liveBasketExtend,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: () => controller.freeze(basket.id!),
              child: Text(l10n.liveBasketCheckout),
            ),
          ),
          IconButton(
            onPressed: () => _confirmCancel(context, ref),
            tooltip: l10n.liveBasketCancel,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.liveBasketEmpty, style: theme.textTheme.titleMedium),
            if (isOpen) ...[
              const SizedBox(height: 8),
              Text(
                l10n.liveBasketEmptyNote,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Closed extends StatelessWidget {
  const _Closed({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.liveBasketClosedTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.liveBasketClosedNote, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          FilledButton(onPressed: onBack, child: Text(l10n.liveBasketBack)),
        ],
      ),
    );
  }
}

/// One full-width primary action where the add-item bar would be.
class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: onPressed, child: Text(label)),
        ),
      ),
    );
  }
}

/// Screen 23: a member looking at a frozen basket the shopper has not priced
/// yet. The stream is still up, so this turns into the settlement button by
/// itself when the shopper settles.
class _Waiting extends StatelessWidget {
  const _Waiting({required this.shopper});

  final String shopper;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.liveBasketWaitingTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.liveBasketWaitingNote(shopper),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// A quiet ink strip under the countdown: why the screen may be behind, or
/// what happened while it was.
class _Strip extends StatelessWidget {
  const _Strip({required this.title, this.note, this.meta});

  final String title;
  final String? note;
  final String? meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onInk = theme.scaffoldBackgroundColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.textTheme.bodyLarge!.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: OpenBasketText.item(onInk).copyWith(fontSize: 14),
                ),
              ),
              if (meta != null)
                Text(
                  meta!,
                  style: OpenBasketText.meta(onInk.withValues(alpha: 0.7)),
                ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 2),
            Text(
              note!,
              style: OpenBasketText.meta(onInk.withValues(alpha: 0.85)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Screen 26: the queue went out, or could not.
class _ReportStrip extends StatelessWidget {
  const _ReportStrip({required this.report});

  final QueueReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (report.dropped.isNotEmpty) {
      return _Strip(
        title: l10n.liveBasketClosedTitle,
        note: l10n.liveBasketDropped(report.dropped.join(', ')),
      );
    }
    return _Strip(
      title: l10n.liveBasketBackOnline(report.sent.length),
      note: l10n.liveBasketBackOnlineNote(report.sent.join(', ')),
    );
  }
}

/// An item that exists only on this phone so far: dashed, greyed, and saying
/// so. It never looks like a row everyone else can see.
class _QueuedRow extends StatelessWidget {
  const _QueuedRow({required this.item});

  final QueuedItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall!.color!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: muted.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.clock, size: 18, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.quantity != null && item.quantity! > 1
                      ? '${item.name}  ×${item.quantity}'
                      : item.name,
                  style: OpenBasketText.item(muted),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.liveBasketQueuedRow,
                  style: OpenBasketText.meta(muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
