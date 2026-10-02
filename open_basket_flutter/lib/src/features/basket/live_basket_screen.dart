import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/failure_message.dart';
import '../../core/formatters.dart';
import '../../core/quantity_format.dart';
import '../../core/router.dart';
import '../../core/server_clock.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../../shared/widgets/item_name.dart';
import '../household/household_controller.dart';
import '../stores/stores_controller.dart';
import 'add_item_bar.dart';
import 'basket_controller.dart';
import 'countdown_banner.dart';
import 'live_basket_controller.dart';
import 'live_basket_state.dart';

/// Screens 08-13 and 22-26. The live basket, for the shopper and for
/// everyone else, and what it looks like once it has closed.
///
/// The two roles are the same screen: the countdown and the item rows are
/// identical, and only the controls differ. Splitting them would mean two
/// places to fix every layout problem.
class LiveBasketScreen extends ConsumerStatefulWidget {
  const LiveBasketScreen({
    required this.basketId,
    this.joined = false,
    super.key,
  });

  final int basketId;

  /// Arrived here because opening a basket found this one already running
  /// (screen 24).
  final bool joined;

  @override
  ConsumerState<LiveBasketScreen> createState() => _LiveBasketScreenState();
}

class _LiveBasketScreenState extends ConsumerState<LiveBasketScreen> {
  /// The shopper's add bar is folded behind the ink + beside "At checkout"
  /// (screen 08 has no bar for the shopper); this unfolds it.
  bool _shopperAdding = false;

  /// "See the whole basket" on a closed basket a member is looking at.
  bool _showWhole = false;

  int get basketId => widget.basketId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveBasketProvider(basketId));
    final basket = state.basket;
    if (basket == null) return const SkeletonScreen();

    final me = ref.watch(myMembershipProvider).value;
    final members = ref.watch(membersProvider).value ?? const [];
    final isShopper = basket.shopperMemberId == me?.id;
    final shopperName = _nameFor(members, basket.shopperMemberId);
    final storeName = (ref.watch(storesProvider).value ?? const <Store>[])
        .where((s) => s.id == basket.storeId)
        .firstOrNull
        ?.name;

    if (basket.status != BasketStatus.open) {
      return _ClosedView(
        basket: basket,
        state: state,
        me: me,
        members: members,
        isShopper: isShopper,
        shopperName: shopperName,
        storeName: storeName,
        showWhole: _showWhole,
        onShowWhole: () => setState(() => _showWhole = true),
      );
    }

    // With the keyboard up there is room for the add bar and a few rows, not
    // for the full countdown card too.
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    final reconnecting = state.connection == LiveConnection.reconnecting;
    final empty = state.items.isEmpty && state.queued.isEmpty;
    final viewers = [
      for (final id in state.viewers)
        if (id != me?.id && id != basket.shopperMemberId)
          (id, _nameFor(members, id)),
    ];

    final Widget bottom;
    if (isShopper && !_shopperAdding) {
      bottom = _ShopperBar(
        basket: basket,
        itemCount: state.items.length,
        others: [
          for (final m in members)
            if (m.leftAt == null && m.id != basket.shopperMemberId) m,
        ],
        onAdd: () => setState(() => _shopperAdding = true),
      );
    } else {
      bottom = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AddItemBar(basketId: basketId),
          if (isShopper)
            Center(
              child: LinkText(
                AppLocalizations.of(context).liveBasketCheckout,
                onTap: () => setState(() => _shopperAdding = false),
              ),
            ),
        ],
      );
    }

    return ObScaffold(
      bottomBar: bottom,
      body: EverySecond(
        builder: (context) {
          final now = ref.read(serverClockProvider).now();
          final left = basket.closesAt.difference(now);
          final urgent = left <= CountdownBanner.lastCall;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.joined && !isShopper && !typing)
                _JoinedNote(basket: basket, shopperName: shopperName),
              CountdownBanner(
                basket: basket,
                compact: typing,
                shopperName: shopperName,
                storeName: storeName,
                isShopper: isShopper,
                viewers: viewers,
                reconnecting: reconnecting,
                quiet: empty,
                onExtend: isShopper && basket.extendCount == 0
                    ? () => _run(context, ref, (c) => c.extend(basketId))
                    : null,
              ),
              // Screen 25: the countdown stays at full strength while
              // offline, because it is the server's clock and not this
              // phone's; the glass strip says why the list may be behind.
              if (reconnecting && !typing)
                const _ReconnectingStrip()
              else if (state.report != null && !typing)
                _ReportNote(report: state.report!)
              else if (urgent && isShopper && !typing)
                _LastCallNote(basket: basket, items: state.items),
              Expanded(
                child: empty
                    ? _EmptyOpen(
                        basketId: basketId,
                        basket: basket,
                        state: state,
                        storeName: storeName,
                        isShopper: isShopper,
                      )
                    : _OpenList(
                        basketId: basketId,
                        basket: basket,
                        state: state,
                        me: me,
                        members: members,
                        isShopper: isShopper,
                        shopperName: shopperName,
                        urgent: urgent,
                        joined: widget.joined,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _nameFor(List<HouseholdMember> members, int memberId) {
  for (final member in members) {
    if (member.id == memberId) return member.displayName;
  }
  return '';
}

/// Runs a shopper action and says so if the server refused it.
///
/// Everything it needs is read before the first await. The basket can close
/// itself while a dialog is up, which takes these buttons off the screen;
/// touching `ref` or `context` after that threw "Using ref when a widget is
/// about to or has been unmounted" and the refusal was never shown — found
/// by tapping cancel with three seconds left.
Future<void> _run(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function(BasketController controller) action,
) async {
  final l10n = AppLocalizations.of(context);
  final controller = ref.read(basketControllerProvider);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action(controller);
  } on Exception catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
  }
}

/// An iOS action sheet for the row (the box beside it ticks in one tap).
Future<void> _markItem(
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
            onPressed: () => Navigator.of(context).pop(ItemStatus.unavailable),
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
  if (choice == null || !context.mounted) return;
  await _setStatus(context, ref, item, choice);
}

Future<void> _setStatus(
  BuildContext context,
  WidgetRef ref,
  BasketItem item,
  ItemStatus status,
) => _run(context, ref, (c) => c.markItem(item.id!, status));

// ------------------------------------------------------------------ open

/// The list while the basket is open: a header with where it stands, then
/// the rows. In the last two minutes, and once the extension is spent, the
/// shopper's list splits into what is still to find and what is got.
class _OpenList extends ConsumerWidget {
  const _OpenList({
    required this.basketId,
    required this.basket,
    required this.state,
    required this.me,
    required this.members,
    required this.isShopper,
    required this.shopperName,
    required this.urgent,
    required this.joined,
  });

  final int basketId;
  final Basket basket;
  final LiveBasketState state;
  final HouseholdMember? me;
  final List<HouseholdMember> members;
  final bool isShopper;
  final String shopperName;
  final bool urgent;
  final bool joined;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final items = state.items;
    final now = ref.read(serverClockProvider).now();
    final got = items.where((i) => i.status == ItemStatus.picked).length;
    final unavailable = items
        .where((i) => i.status == ItemStatus.unavailable)
        .length;
    final mine = items.where((i) => i.requesterMemberId == me?.id).length;
    final reconnecting = state.connection == LiveConnection.reconnecting;
    final extended = basket.extendCount > 0;
    final split = isShopper && (urgent || extended);

    // The header: how far along it is, and one quiet fact on the right.
    final String headerText;
    final Widget? headerTrailing;
    final quiet = OpenBasketText.meta(ob.meta).copyWith(fontSize: 12);
    if (reconnecting) {
      headerText = [
        l10n.liveBasketItemsHeader(items.length + state.queued.length),
        if (state.queued.isNotEmpty)
          l10n.liveBasketQueuedCount(state.queued.length),
      ].join(' · ');
      headerTrailing = state.lastSyncedAt == null
          ? null
          : Text(
              l10n.liveBasketLastSynced(
                DateFormat.Hm().format(state.lastSyncedAt!),
              ),
              style: quiet,
            );
    } else if (split) {
      final toFind = items.where((i) => i.status == ItemStatus.requested);
      headerText = urgent
          ? l10n.liveBasketStillToFind(toFind.length)
          : l10n.liveBasketStillToFindPlain;
      headerTrailing = urgent
          ? Text(l10n.liveBasketGotUnavailable(got, unavailable), style: quiet)
          : null;
    } else if (isShopper) {
      headerText = [
        l10n.liveBasketItemsHeader(items.length),
        if (got > 0) l10n.liveBasketGot(got),
      ].join(' · ');
      final latest = items
          .where((i) => i.requesterMemberId != me?.id)
          .fold<BasketItem?>(
            null,
            (a, b) => a == null || b.addedAt.isAfter(a.addedAt) ? b : a,
          );
      final ago = latest == null ? null : now.difference(latest.addedAt);
      headerTrailing = ago == null || ago > const Duration(minutes: 30)
          ? null
          : Text(
              l10n.liveBasketAddedAgo(
                _nameFor(members, latest!.requesterMemberId),
                describeAgo(l10n, ago.isNegative ? Duration.zero : ago),
              ),
              style: quiet,
            );
    } else {
      headerText = joined
          ? l10n.liveBasketItemsSoFar(items.length)
          : l10n.liveBasketItemsHeader(items.length);
      headerTrailing = state.report != null && state.report!.dropped.isEmpty
          ? Text(l10n.liveBasketInSync, style: quiet)
          : mine > 0
          ? Text(
              l10n.liveBasketYours(mine),
              style: OpenBasketText.meta(
                ob.onGround,
              ).copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            )
          : joined
          ? Text(l10n.liveBasketNothingYours, style: quiet)
          : null;
    }

    Widget row(BasketItem item) => _ItemRow(
      key: ValueKey(item.id),
      item: item,
      requesterName: _nameFor(members, item.requesterMemberId),
      shopperName: shopperName,
      mine: item.requesterMemberId == me?.id,
      isShopper: isShopper,
      landed:
          state.report?.sent.contains(item.name) == true &&
          item.requesterMemberId == me?.id,
      arrivedJustNow:
          item.requesterMemberId != me?.id &&
          now.difference(item.addedAt) < const Duration(seconds: 4),
      // ADR-005: the shopper ticks things off while walking the aisles.
      // Prices wait for the checkout screen.
      onTick: isShopper
          ? () => _setStatus(
              context,
              ref,
              item,
              item.status == ItemStatus.requested
                  ? ItemStatus.picked
                  : ItemStatus.requested,
            )
          : null,
      onTap: isShopper ? () => _markItem(context, ref, item) : null,
      // Rule 3 in its narrowest form: your own item, while still open.
      onRemove: item.requesterMemberId == me?.id
          ? () => _run(context, ref, (c) => c.removeItem(item.id!))
          : null,
    );

    final ordered = isShopper
        ? [
            ...items.where((i) => i.status == ItemStatus.requested),
            ...items.where((i) => i.status != ItemStatus.requested),
          ]
        : items;
    final toFind = ordered.where((i) => i.status == ItemStatus.requested);
    final done = ordered.where((i) => i.status != ItemStatus.requested);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        if (split && extended && !urgent) ...[
          _HowExtending(basket: basket),
          const SizedBox(height: 16),
        ],
        SectionLabel(headerText, trailing: headerTrailing),
        const SizedBox(height: 6),
        for (final q in state.queued)
          _QueuedRow(
            item: q,
            memberId: me?.id ?? 0,
            name: me?.displayName ?? '',
          ),
        if (split) ...[
          ...toFind.map(row),
          if (done.isNotEmpty) ...[
            const SizedBox(height: 14),
            SectionLabel(l10n.liveBasketGotSection),
            const SizedBox(height: 6),
            ...done.map(row),
          ],
        ] else
          ...ordered.map(row),
        if (joined && !isShopper) ...[
          const SizedBox(height: 22),
          UsualChips(basketId: basketId),
          const SizedBox(height: 16),
          IconNote(
            icon: CupertinoIcons.clock,
            text: l10n.liveBasketOpenOwnLater(
              DateFormat.Hm().format(basket.closesAt.toLocal()),
            ),
          ),
        ],
      ],
    );
  }
}

/// One item: the asker's square, the name with its amount, a note, and on
/// the right the shopper's box or the member's "YOU". 64px, the whole row
/// taps.
class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.requesterName,
    required this.shopperName,
    required this.mine,
    required this.isShopper,
    required this.onTick,
    required this.onTap,
    required this.onRemove,
    this.arrivedJustNow = false,
    this.landed = false,
    super.key,
  });

  final BasketItem item;
  final String requesterName;
  final String shopperName;
  final bool mine;
  final bool isShopper;
  final VoidCallback? onTick;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  /// Added by someone else in the last few seconds.
  final bool arrivedJustNow;

  /// Came in from this phone's offline queue just now (screen 26).
  final bool landed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final gone = item.status == ItemStatus.unavailable;
    final got = item.status == ItemStatus.picked;
    final settled = gone || got;

    final String? sub;
    if (gone) {
      sub = l10n.itemNotAvailable;
    } else if (got) {
      sub = isShopper ? l10n.itemGotIt : l10n.itemHasIt(shopperName);
    } else if (landed) {
      sub = l10n.itemAddedAt(DateFormat.Hm().format(item.addedAt.toLocal()));
    } else {
      sub = item.note;
    }

    final Widget? trailing;
    if (isShopper) {
      trailing = TickBox(
        state: got
            ? TickState.got
            : gone
            ? TickState.unavailable
            : TickState.empty,
        onTap: onTick,
      );
    } else if (got) {
      trailing = const TickBox(state: TickState.got);
    } else if (mine && !gone) {
      trailing = Tag(l10n.youTag);
    } else {
      trailing = null;
    }

    Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: ob.rule)),
        ),
        child: Row(
          children: [
            PersonAvatar(
              memberId: item.requesterMemberId,
              name: requesterName,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (settled)
                    Text(
                      item.name,
                      style: OpenBasketText.item(ob.meta).copyWith(
                        decoration: TextDecoration.lineThrough,
                        decorationColor: ob.meta,
                      ),
                    )
                  else
                    ItemName.of(item, style: OpenBasketText.item(ob.onGround)),
                  if (sub != null && sub.isNotEmpty)
                    Text(
                      sub,
                      style: OpenBasketText.meta(ob.meta).copyWith(
                        fontWeight: gone ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing],
          ],
        ),
      ),
    );

    if (onRemove != null) {
      row = Dismissible(
        key: ValueKey('remove-${item.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          onRemove!();
          return false;
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            l10n.liveBasketRemove,
            style: OpenBasketText.body(
              Theme.of(context).colorScheme.error,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        child: row,
      );
    }

    if (!arrivedJustNow) return row;
    // A row someone else added a moment ago slides and fades in, so a
    // glance catches it. Your own rows just appear — you know you added them.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (final context, final t, final child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 12),
          child: child,
        ),
      ),
      child: row,
    );
  }
}

/// An item that exists only on this phone so far: dashed, greyed, and saying
/// so. It never looks like a row everyone else can see.
class _QueuedRow extends StatelessWidget {
  const _QueuedRow({
    required this.item,
    required this.memberId,
    required this.name,
  });

  final QueuedItem item;
  final int memberId;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: CustomPaint(
        painter: DashedRectPainter(color: ob.faint, radius: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            color: ob.tonal.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              PersonAvatar(memberId: memberId, name: name, faded: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ItemName(
                      name: item.name,
                      quantity: item.quantity ?? 1,
                      unit: item.unit ?? ItemUnit.piece,
                      style: OpenBasketText.item(ob.meta),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(CupertinoIcons.clock, size: 12, color: ob.meta),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            l10n.liveBasketQueuedRow,
                            style:
                                OpenBasketText.meta(
                                  ob.meta,
                                ).copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen 10: nothing on the list yet. The moment that decides whether the
/// app works socially, so it does real work: who was told, what you usually
/// ask for, who is looking, and a nudge for the rest.
class _EmptyOpen extends ConsumerStatefulWidget {
  const _EmptyOpen({
    required this.basketId,
    required this.basket,
    required this.state,
    required this.storeName,
    required this.isShopper,
  });

  final int basketId;
  final Basket basket;
  final LiveBasketState state;
  final String? storeName;
  final bool isShopper;

  @override
  ConsumerState<_EmptyOpen> createState() => _EmptyOpenState();
}

class _EmptyOpenState extends ConsumerState<_EmptyOpen> {
  bool _nudging = false;

  Future<void> _nudge() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _nudging = true);
    try {
      final count = await ref
          .read(basketControllerProvider)
          .nudge(widget.basketId);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.liveBasketNudged(count))),
      );
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    } finally {
      if (mounted) setState(() => _nudging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final me = ref.watch(myMembershipProvider).value;
    final members = ref.watch(activeMembersProvider).value ?? const [];
    final basket = widget.basket;

    // Who the "a basket opened" push went to: everyone but the shopper who
    // has it switched on — the same rule the server sends by (ADR-043).
    final told = [
      for (final m in members)
        if (m.id != basket.shopperMemberId &&
            m.id != me?.id &&
            m.notifyBasketOpened)
          m.displayName,
    ];
    final looking = [
      for (final id in widget.state.viewers)
        if (id != me?.id && id != basket.shopperMemberId)
          members.where((m) => m.id == id).firstOrNull,
    ].nonNulls.toList();
    final others = members
        .where((m) => m.id != me?.id && m.id != basket.shopperMemberId)
        .length;
    final someoneMissing = looking.length < others;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      children: [
        Text(
          l10n.liveBasketEmpty,
          style: OpenBasketText.display(
            ob.onGround,
          ).copyWith(fontSize: 24, letterSpacing: -0.48),
        ),
        const SizedBox(height: 8),
        Text(
          told.isEmpty
              ? l10n.liveBasketEmptyNoOne
              : l10n.liveBasketEmptyTold(joinNames(l10n, told)),
          style: OpenBasketText.body(ob.meta),
        ),
        const SizedBox(height: 22),
        UsualChips(
          basketId: widget.basketId,
          note: widget.storeName == null
              ? l10n.liveBasketUsuallyFromAny
              : l10n.liveBasketUsuallyFrom(widget.storeName!),
        ),
        if (others > 0) ...[
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: ob.onGround, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (looking.isNotEmpty) ...[
                      AvatarStack(
                        size: 24,
                        people: [
                          for (final m in looking) (m.id!, m.displayName),
                        ],
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        looking.isEmpty
                            ? l10n.liveBasketNobodyLooking
                            : l10n.liveBasketLookingNow(
                                joinNames(
                                  l10n,
                                  [for (final m in looking) m.displayName],
                                ),
                                looking.length,
                              ),
                        style: OpenBasketText.body(
                          ob.onGround,
                        ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                if (someoneMissing) ...[
                  const SizedBox(height: 12),
                  InkButton(
                    label: l10n.liveBasketNudge,
                    height: 46,
                    onPressed: _nudging ? null : _nudge,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Screen 24: arriving at someone else's run because opening your own lost
/// the race. Not an error.
class _JoinedNote extends ConsumerWidget {
  const _JoinedNote({required this.basket, required this.shopperName});

  final Basket basket;
  final String shopperName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final ago = ref.read(serverClockProvider).now().difference(basket.openedAt);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Glass(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                CupertinoIcons.info_circle,
                size: 17,
                color: ob.onGround,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.liveBasketJoinedAgo(
                      shopperName,
                      describeAgo(l10n, ago.isNegative ? Duration.zero : ago),
                    ),
                    style: OpenBasketText.body(
                      ob.onGround,
                    ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.liveBasketJoinedNote,
                    style: OpenBasketText.meta(ob.meta),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 25's glass strip under the card.
class _ReconnectingStrip extends StatelessWidget {
  const _ReconnectingStrip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Glass(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Icon(CupertinoIcons.arrow_clockwise, size: 18, color: ob.onGround),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.liveBasketReconnecting,
                    style: OpenBasketText.body(
                      ob.onGround,
                    ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    l10n.liveBasketReconnectingNote,
                    style: OpenBasketText.meta(ob.meta).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 26: the queue went out, or could not.
class _ReportNote extends StatelessWidget {
  const _ReportNote({required this.report});

  final QueueReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: report.dropped.isNotEmpty
          ? InkNotice(
              title: l10n.liveBasketClosedTitle,
              body: l10n.liveBasketDropped(report.dropped.join(', ')),
            )
          : InkNotice(
              iconOnSignal: true,
              icon: CupertinoIcons.checkmark_alt,
              title: l10n.liveBasketBackOnline(report.sent.length),
              body: report.sent.length == 1
                  ? l10n.liveBasketBackOnlineOne(report.sent.single)
                  : l10n.liveBasketBackOnlineNote(report.sent.join(', ')),
            ),
    );
  }
}

/// Screen 11: the shopper is told who the server told. The same rule as the
/// reminder: everyone but the shopper with it switched on and nothing on
/// the list yet.
class _LastCallNote extends ConsumerWidget {
  const _LastCallNote({required this.basket, required this.items});

  final Basket basket;
  final List<BasketItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final members = ref.watch(activeMembersProvider).value ?? const [];
    final asked = {for (final i in items) i.requesterMemberId};
    final told = [
      for (final m in members)
        if (m.id != basket.shopperMemberId &&
            m.notifyClosingSoon &&
            !asked.contains(m.id))
          m.displayName,
    ];
    if (told.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Glass(
        radius: 14,
        shadow: false,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            Container(width: 7, height: 7, color: ob.onGround),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.liveBasketLastCallTold(joinNames(l10n, told), told.length),
                style: OpenBasketText.meta(ob.meta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 12: once the extension is spent, what the hatch means.
class _HowExtending extends StatelessWidget {
  const _HowExtending({required this.basket});

  final Basket basket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final original =
        basket.closesAt.difference(basket.openedAt).inMinutes -
        5 * basket.extendCount;
    return RaisedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(l10n.liveBasketHowExtending),
          const SizedBox(height: 6),
          Text(
            l10n.liveBasketHowExtendingNote,
            style: OpenBasketText.body(ob.onGround),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 32,
                height: 6,
                decoration: BoxDecoration(
                  color: ob.onGround,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.liveBasketOriginal(original),
                style: OpenBasketText.meta(ob.meta),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 32,
                height: 6,
                child: CustomPaint(painter: _MiniHatch(color: ob.meta)),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.liveBasketExtensionLegend,
                style: OpenBasketText.meta(ob.meta),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniHatch extends CustomPainter {
  const _MiniHatch({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(2)),
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (var x = -size.height; x < size.width; x += 4) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MiniHatch old) => old.color != color;
}

/// The shopper's bar: freeze, the + that unfolds the add bar, and cancel as
/// a labelled action rather than a bare ×.
class _ShopperBar extends ConsumerWidget {
  const _ShopperBar({
    required this.basket,
    required this.itemCount,
    required this.others,
    required this.onAdd,
  });

  final Basket basket;
  final int itemCount;
  final List<HouseholdMember> others;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: InkButton(
                label: l10n.liveBasketCheckout,
                height: 52,
                onPressed: () =>
                    _run(context, ref, (c) => c.freeze(basket.id!)),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: l10n.liveBasketAdd,
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ob.onGround,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    CupertinoIcons.add,
                    size: 22,
                    color: ob.dark
                        ? OpenBasketColors.ink
                        : OpenBasketColors.signal,
                  ),
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _confirmCancel(context, ref),
          child: SizedBox(
            height: kMinTapTarget,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.xmark, size: 14, color: ob.meta),
                const SizedBox(width: 6),
                Text(
                  l10n.liveBasketCancelThis,
                  style: OpenBasketText.body(
                    ob.meta,
                  ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showGlassSheet<bool>(
      context: context,
      builder: (_) =>
          _CancelSheet(basket: basket, itemCount: itemCount, told: others),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(context, ref, (c) => c.cancel(basket.id!));
  }
}

/// Screen 13: what cancelling does, before it does it.
class _CancelSheet extends ConsumerWidget {
  const _CancelSheet({
    required this.basket,
    required this.itemCount,
    required this.told,
  });

  final Basket basket;
  final int itemCount;
  final List<HouseholdMember> told;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitle(
            l10n.cancelSheetTitle,
            subtitle: l10n.cancelSheetNote,
            fontSize: 27,
          ),
          const SizedBox(height: 20),
          TonalCard(
            child: Column(
              children: [
                EverySecond(
                  builder: (context) {
                    final left = basket.closesAt.difference(
                      ref.read(serverClockProvider).now(),
                    );
                    final l = left.isNegative ? Duration.zero : left;
                    return FactRow(
                      label: l10n.cancelSheetTimeLeft,
                      value:
                          '${l.inMinutes}:${(l.inSeconds % 60).toString().padLeft(2, '0')}',
                    );
                  },
                ),
                Divider(height: 24, color: ob.rule),
                FactRow(label: l10n.cancelSheetDropped, value: '$itemCount'),
                if (told.isNotEmpty) ...[
                  Divider(height: 24, color: ob.rule),
                  FactRow(
                    label: l10n.cancelSheetTold,
                    value: '',
                    valueWidget: AvatarStack(
                      size: 26,
                      max: 4,
                      people: [for (final m in told) (m.id!, m.displayName)],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          IconNote(text: l10n.cancelSheetHistory),
          const SizedBox(height: 20),
          InkButton(
            label: l10n.cancelSheetYes,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 10),
          OutlineButton(
            label: l10n.cancelSheetKeep,
            quiet: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- closed

/// Screens 22-23 (and the shopper's frozen view): the grey card, how it
/// ended, what you asked for, and where you stand.
class _ClosedView extends ConsumerWidget {
  const _ClosedView({
    required this.basket,
    required this.state,
    required this.me,
    required this.members,
    required this.isShopper,
    required this.shopperName,
    required this.storeName,
    required this.showWhole,
    required this.onShowWhole,
  });

  final Basket basket;
  final LiveBasketState state;
  final HouseholdMember? me;
  final List<HouseholdMember> members;
  final bool isShopper;
  final String shopperName;
  final String? storeName;
  final bool showWhole;
  final VoidCallback onShowWhole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final ended = (basket.frozenAt ?? basket.closesAt).toLocal();
    final at = DateFormat.Hm().format(ended);
    final ran = (basket.frozenAt ?? basket.closesAt)
        .difference(basket.openedAt)
        .inMinutes;
    final settled = basket.status == BasketStatus.settled;
    final frozen = basket.status == BasketStatus.frozen;
    final cancelled = basket.status == BasketStatus.cancelled;

    final String title;
    final String body;
    if (cancelled) {
      title = l10n.countdownCancelledBy(shopperName);
      body = l10n.countdownCancelledNote;
    } else if (isShopper && frozen) {
      title = l10n.liveBasketYouFroze(at);
      body = l10n.liveBasketYouFrozeNote;
    } else {
      title = basket.closedAutomatically
          ? l10n.countdownClosedItself(at)
          : l10n.countdownClosedBy(shopperName, at);
      final how = basket.closedAutomatically
          ? l10n.countdownClosedItselfNote(ran < 1 ? 1 : ran)
          : l10n.countdownListFinal;
      body =
          '$how ${settled ? l10n.liveBasketNothingWaiting : l10n.liveBasketStillAtTill(shopperName)}';
    }

    final whole = isShopper || showWhole || cancelled;
    final shown = whole
        ? state.items
        : state.items.where((i) => i.requesterMemberId == me?.id).toList();

    final Widget primary;
    var backLink = true;
    if (isShopper && frozen) {
      backLink = false;
      primary = PrimaryButton(
        label: l10n.liveBasketEnterPrices,
        onPressed: () => context.push('${Routes.basket}/${basket.id}/checkout'),
      );
    } else if (settled) {
      primary = InkButton(
        label: l10n.liveBasketSeeWholeRun,
        onPressed: () =>
            context.push('${Routes.basket}/${basket.id}/settlement'),
      );
    } else if (frozen && !showWhole) {
      primary = InkButton(
        label: l10n.liveBasketSeeWholeBasket,
        onPressed: onShowWhole,
      );
    } else {
      backLink = false;
      primary = InkButton(
        label: l10n.liveBasketBackHome,
        onPressed: () => context.go(Routes.home),
      );
    }

    return ObScaffold(
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          if (backLink)
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.go(Routes.home),
                child: SizedBox(
                  height: kMinTapTarget,
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      l10n.liveBasketBackHome,
                      style: OpenBasketText.body(
                        ob.meta,
                      ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          CountdownBanner(
            basket: basket,
            shopperName: shopperName,
            storeName: storeName,
            isShopper: isShopper,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: OpenBasketText.display(ob.onGround).copyWith(
                    fontSize: 27,
                    height: 1.12,
                    letterSpacing: -0.81,
                  ),
                ),
                const SizedBox(height: 7),
                Text(body, style: OpenBasketText.body(ob.meta)),
                const SizedBox(height: 20),
                SectionLabel(
                  whole
                      ? l10n.liveBasketWholeBasket
                      : l10n.liveBasketWhatYouAsked,
                ),
                const SizedBox(height: 6),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      whole
                          ? l10n.liveBasketEmptyClosed
                          : l10n.liveBasketAskedNothing,
                      style: OpenBasketText.meta(ob.meta),
                    ),
                  ),
                for (final item in shown)
                  _AskedRow(
                    item: item,
                    shopperName: shopperName,
                    requesterName: whole
                        ? _nameFor(members, item.requesterMemberId)
                        : null,
                    currencyCode: basket.currencyCode,
                    showPrice: settled,
                    cancelled: cancelled,
                  ),
                if (!isShopper && settled) ...[
                  const SizedBox(height: 20),
                  _MyLine(basket: basket, me: me, members: members),
                ],
                if (!isShopper && frozen) ...[
                  const SizedBox(height: 20),
                  _NothingToSettle(shopperName: shopperName),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of a closed basket: the shopper's mark, the item, who got it, and
/// its price once settled.
class _AskedRow extends StatelessWidget {
  const _AskedRow({
    required this.item,
    required this.shopperName,
    required this.requesterName,
    required this.currencyCode,
    required this.showPrice,
    required this.cancelled,
  });

  final BasketItem item;
  final String shopperName;

  /// Set when the list is everyone's, not just yours.
  final String? requesterName;
  final String currencyCode;
  final bool showPrice;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final got = item.status == ItemStatus.picked;
    final gone = item.status == ItemStatus.unavailable;
    final name =
        '${item.name} ${QuantityFormat.label(item.quantity, item.unit)}';
    final sub = [
      ?requesterName,
      if (!cancelled)
        got
            ? l10n.itemGotBy(shopperName)
            : gone
            ? l10n.itemNotAvailable
            : l10n.itemNotPicked,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: ob.rule)),
      ),
      child: Row(
        children: [
          if (!cancelled) ...[
            IgnorePointer(
              child: SizedBox(
                width: 32,
                child: TickBox(
                  state: got
                      ? TickState.got
                      : gone
                      ? TickState.unavailable
                      : TickState.empty,
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: OpenBasketText.item(gone ? ob.meta : ob.onGround)
                      .copyWith(
                        decoration: gone ? TextDecoration.lineThrough : null,
                        decorationColor: ob.meta,
                      ),
                ),
                if (sub.isNotEmpty)
                  Text(
                    sub,
                    style: OpenBasketText.meta(ob.meta).copyWith(
                      fontWeight: gone ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          if (showPrice)
            Text(
              got && item.priceMinor != null
                  ? MoneyFormat.format(item.priceMinor!, currencyCode)
                  : '—',
              style: OpenBasketText.money(
                got ? ob.onGround : ob.meta,
              ).copyWith(fontSize: 16),
            ),
        ],
      ),
    );
  }
}

/// "K  You owe Kaan  ₺84.50 items + ₺0.50 gap  ₺85.00" (screen 22).
class _MyLine extends ConsumerWidget {
  const _MyLine({
    required this.basket,
    required this.me,
    required this.members,
  });

  final Basket basket;
  final HouseholdMember? me;
  final List<HouseholdMember> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final lines = ref.watch(settlementProvider(basket.id!)).value;
    if (lines == null) return const SkeletonList(rows: 1);
    final mine = lines.where((l) => l.fromMemberId == me?.id).firstOrNull;
    String money(int minor) => MoneyFormat.format(minor, basket.currencyCode);
    if (mine == null) {
      return TonalCard(
        child: Text(
          l10n.liveBasketNothingToPay,
          style: OpenBasketText.body(ob.onGround),
        ),
      );
    }
    final to = _nameFor(members, mine.toMemberId);
    return RaisedCard(
      child: Row(
        children: [
          PersonAvatar(memberId: mine.toMemberId, name: to),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.liveBasketYouOwe(to),
                  style: OpenBasketText.title(ob.onGround),
                ),
                Text(
                  mine.receiptGapMinor == 0
                      ? l10n.liveBasketLineItems(money(mine.itemsMinor))
                      : l10n.liveBasketLineParts(
                          money(mine.itemsMinor),
                          money(mine.receiptGapMinor),
                        ),
                  style: OpenBasketText.meta(ob.meta).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          FittedBox(
            child: Text(
              money(mine.amountMinor),
              style: OpenBasketText.money(ob.onGround).copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen 23: frozen, not priced yet. The stream is still up, so this turns
/// into the settled view by itself when the shopper settles.
class _NothingToSettle extends StatelessWidget {
  const _NothingToSettle({required this.shopperName});

  final String shopperName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: ob.onGround, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.clock, size: 17, color: ob.onGround),
              const SizedBox(width: 8),
              Text(
                l10n.liveBasketWaitingTitle,
                style: OpenBasketText.title(ob.onGround, fontSize: 15.5),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.liveBasketWaitingNote(shopperName),
            style: OpenBasketText.meta(ob.meta).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
