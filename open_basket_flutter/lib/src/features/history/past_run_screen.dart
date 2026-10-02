import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/formatters.dart';
import '../../core/quantity_format.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../basket/checkout_screen.dart';
import '../household/household_controller.dart';
import '../stores/stores_controller.dart';
import 'history_controller.dart';
import 'history_screen.dart';

/// Screens 29 and 30. One finished run, read-only: settled with its prices
/// and who paid whom, or cancelled with what was dropped.
///
/// Reads `history.get` rather than the live stream: a finished run does not
/// change, and a history screen should not hold a socket open.
class PastRunScreen extends ConsumerWidget {
  const PastRunScreen({required this.basketId, super.key});

  final int basketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final data = ref.watch(pastRunProvider(basketId));
    final members = ref.watch(membersProvider).value ?? const [];
    final stores = ref.watch(storesProvider).value ?? const <Store>[];

    final value = data.value;
    if (value == null) {
      if (!data.hasError) return const SkeletonScreen(back: true);
      return ObScaffold(
        back: true,
        backLabel: l10n.historyTitle,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorCard(
            title: l10n.commonOffline,
            body: l10n.commonOfflineRetryNote,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(pastRunProvider(basketId)),
          ),
        ),
      );
    }

    final basket = value.run.basket!;
    final items = value.run.items ?? const <BasketItem>[];
    final lines = value.lines;
    final settled = basket.status == BasketStatus.settled;
    final currency = basket.currencyCode;
    String money(int minor) => MoneyFormat.format(minor, currency);
    HouseholdMember? member(int id) =>
        members.where((m) => m.id == id).firstOrNull;
    String name(int id) => member(id)?.displayName ?? '';

    final store = stores.where((s) => s.id == basket.storeId).firstOrNull;
    final shopper = name(basket.shopperMemberId);
    final ended = basket.frozenAt;
    final ranMinutes = ended?.difference(basket.openedAt).inMinutes;
    final priced = items
        .where((i) => i.status == ItemStatus.picked && i.priceMinor != null)
        .fold<int>(0, (sum, i) => sum + i.priceMinor!);
    final receipt = basket.receiptTotalMinor ?? priced;
    final unavailable = items
        .where((i) => i.status == ItemStatus.unavailable)
        .length;

    final subtitle = [
      l10n.historyWhen(
        describeWhen(l10n, basket.openedAt, DateTime.now()),
        shopper,
      ),
      if (ranMinutes != null)
        settled
            ? l10n.historyRan(ranMinutes)
            : l10n.historyStoppedAfter(ranMinutes < 1 ? 1 : ranMinutes),
    ].join(' · ');

    // Grouped by who asked, members in their household order.
    final groups = <int, List<BasketItem>>{
      for (final m in members) m.id!: <BasketItem>[],
    };
    for (final item in items) {
      groups.putIfAbsent(item.requesterMemberId, () => []).add(item);
    }
    groups.removeWhere((_, theirs) => theirs.isEmpty);

    final summary = [
      for (final line in lines)
        l10n.settlementShareLine(
          name(line.fromMemberId),
          name(line.toMemberId),
          money(line.amountMinor),
        ),
    ].join('\n');
    final gap = receipt - priced;
    final share = lines.isEmpty ? 0 : lines.first.receiptGapMinor;

    return ObScaffold(
      back: true,
      backLabel: l10n.historyTitle,
      bottomBar: settled && lines.isNotEmpty
          ? Builder(
              builder: (buttonContext) => OutlineButton(
                label: l10n.settlementShare,
                icon: CupertinoIcons.share,
                onPressed: () {
                  final box = buttonContext.findRenderObject() as RenderBox?;
                  SharePlus.instance.share(
                    ShareParams(
                      text: summary,
                      sharePositionOrigin: box == null
                          ? null
                          : box.localToGlobal(Offset.zero) & box.size,
                    ),
                  );
                },
              ),
            )
          : FilledButton(
              onPressed: null,
              child: Text(l10n.historyNothingToShare),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: settled
                ? Tag(l10n.historySettled, icon: CupertinoIcons.checkmark_alt)
                : Tag(
                    l10n.historyCancelled,
                    icon: CupertinoIcons.xmark,
                    outlined: true,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            store?.name ?? l10n.historyNoStore,
            style: OpenBasketText.display(settled ? ob.onGround : ob.meta),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: OpenBasketText.body(ob.meta).copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          if (settled) ...[
            Row(
              children: [
                _Stat(value: '${items.length}', label: l10n.historyStatItems),
                const SizedBox(width: 8),
                _Stat(
                  value: '$unavailable',
                  label: l10n.historyStatUnavailable,
                ),
                const SizedBox(width: 8),
                _Stat(
                  value: money(receipt),
                  label: l10n.historyStatReceipt,
                  ink: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final entry in groups.entries) ...[
              _Person(
                member: member(entry.key),
                total: money(
                  entry.value
                      .where(
                        (i) =>
                            i.status == ItemStatus.picked &&
                            i.priceMinor != null,
                      )
                      .fold<int>(0, (sum, i) => sum + i.priceMinor!),
                ),
              ),
              for (final item in entry.value)
                _ItemLine(
                  item: item,
                  trailing: item.status == ItemStatus.unavailable
                      ? l10n.itemNotAvailable
                      : money(item.priceMinor ?? 0),
                ),
            ],
            const SizedBox(height: 18),
            TonalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionLabel(l10n.historyHowSettled),
                  const SizedBox(height: 4),
                  if (lines.isEmpty)
                    Text(
                      l10n.settlementNobody,
                      style: OpenBasketText.body(ob.onGround),
                    )
                  else
                    for (final line in lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.historyLine(
                                  name(line.fromMemberId),
                                  name(line.toMemberId),
                                ),
                                style: OpenBasketText.body(
                                  ob.onGround,
                                ).copyWith(fontSize: 14),
                              ),
                            ),
                            Text(
                              money(line.amountMinor),
                              style: OpenBasketText.mono(
                                color: ob.onGround,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  if (gap != 0 && share != 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n.historyGapNote(money(share.abs()), money(gap.abs())),
                      style: OpenBasketText.meta(
                        ob.meta,
                      ).copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            // Screen 30.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ob.tonal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ob.faint),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.lock, size: 16, color: ob.meta),
                      const SizedBox(width: 8),
                      Text(
                        l10n.historyNobody,
                        style: OpenBasketText.title(ob.meta, fontSize: 15.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.historyCancelledNote(shopper),
                    style: OpenBasketText.meta(ob.meta).copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 20),
              SectionLabel(l10n.historyWhatWasInIt),
              const SizedBox(height: 6),
              for (final item in items)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: ob.rule)),
                  ),
                  child: Row(
                    children: [
                      PersonAvatar(
                        memberId: item.requesterMemberId,
                        name: name(item.requesterMemberId),
                        size: 28,
                        faded: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.name} ${QuantityFormat.label(item.quantity, item.unit)}',
                              style: OpenBasketText.item(
                                ob.meta,
                              ).copyWith(fontSize: 15),
                            ),
                            Text(
                              l10n.historyAskedDropped(
                                name(item.requesterMemberId),
                              ),
                              style: OpenBasketText.meta(
                                ob.meta,
                              ).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 20),
            SectionLabel(l10n.historyHowItRan),
            const SizedBox(height: 6),
            _Fact(
              label: l10n.historyOpened,
              value: l10n.historyOpenedFor(
                DateFormat.Hm().format(basket.openedAt.toLocal()),
                basket.closesAt.difference(basket.openedAt).inMinutes,
              ),
            ),
            if (ended != null)
              _Fact(
                label: l10n.historyCancelledByName(shopper),
                value: DateFormat.Hm().format(ended.toLocal()),
              ),
            _Fact(label: l10n.historyPriced, value: l10n.historyNothing),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.ink = false});

  final String value;
  final String label;

  /// The receipt: the one number that is the run, on ink.
  final bool ink;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    // The receipt tile inverts the ground: ink on paper, paper in the dark.
    final fg = ink ? ob.ground : ob.onGround;
    return Expanded(
      flex: ink ? 5 : 4,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: ink ? ob.onGround : ob.tonal,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: OpenBasketText.mono(color: fg, fontSize: ink ? 18 : 20),
              ),
            ),
            Text(
              label,
              style: OpenBasketText.meta(
                ink
                    ? (ob.dark
                          ? const Color(0xFF4A4A46)
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

class _Person extends StatelessWidget {
  const _Person({required this.member, required this.total});

  final HouseholdMember? member;
  final String total;

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
            member?.displayName ?? '',
            style: OpenBasketText.body(
              ob.onGround,
            ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: ob.rule)),
          const SizedBox(width: 8),
          Text(
            total,
            style: OpenBasketText.mono(
              color: ob.meta,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemLine extends StatelessWidget {
  const _ItemLine({required this.item, this.trailing});

  final BasketItem item;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall!.color!;
    final gone = item.status == ItemStatus.unavailable;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.name} ${QuantityFormat.label(item.quantity, item.unit)}',
                  style:
                      OpenBasketText.item(
                        gone ? muted : theme.textTheme.bodyLarge!.color!,
                      ).copyWith(
                        fontSize: 15,
                        decoration: gone ? TextDecoration.lineThrough : null,
                        decorationColor: muted,
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: gone
                  ? OpenBasketText.meta(muted).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    )
                  : OpenBasketText.money(
                      theme.textTheme.bodyLarge!.color!,
                    ).copyWith(fontSize: 15),
            ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: OpenBasketText.body(ob.meta).copyWith(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: OpenBasketText.mono(color: ob.onGround, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
