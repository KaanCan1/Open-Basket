import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
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
    final theme = Theme.of(context);
    final data = ref.watch(pastRunProvider(basketId));
    final members = ref.watch(membersProvider).value ?? const [];
    final stores = ref.watch(storesProvider).value ?? const <Store>[];

    final value = data.value;
    if (value == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: data.hasError
              ? Text(l10n.commonOffline, style: theme.textTheme.bodySmall)
              : const CircularProgressIndicator(),
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
      if (settled && ranMinutes != null) l10n.historyRan(ranMinutes),
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

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Text(
            settled ? l10n.historySettled : l10n.historyCancelled,
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 6),
          Text(
            store?.name ?? l10n.historyNoStore,
            style: theme.textTheme.displayLarge,
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          if (settled) ...[
            Row(
              children: [
                _Stat(value: '${items.length}', label: l10n.historyStatItems),
                _Stat(
                  value: '$unavailable',
                  label: l10n.historyStatUnavailable,
                ),
                _Stat(value: money(receipt), label: l10n.historyStatReceipt),
              ],
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            Text(l10n.historyHowSettled, style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            if (lines.isEmpty)
              Text(l10n.settlementNobody, style: theme.textTheme.titleMedium)
            else
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.historyLine(
                            name(line.fromMemberId),
                            name(line.toMemberId),
                          ),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        money(line.amountMinor),
                        style: OpenBasketText.money(
                          theme.textTheme.bodyLarge!.color!,
                        ),
                      ),
                    ],
                  ),
                ),
            if (gap != 0 && share != 0) ...[
              const SizedBox(height: 4),
              Text(
                l10n.historyGapNote(money(share.abs()), money(gap.abs())),
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (lines.isNotEmpty) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: summary));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settlementCopied)),
                  );
                },
                child: Text(l10n.settlementCopy),
              ),
            ],
          ] else ...[
            // Screen 30.
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.historyNobody, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    l10n.historyCancelledNote(shopper),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(l10n.historyWhatWasInIt, style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              for (final item in items)
                _ItemLine(
                  item: item,
                  subtitle: l10n.historyAskedDropped(
                    name(item.requesterMemberId),
                  ),
                  dropped: true,
                ),
            ],
            const SizedBox(height: 24),
            Text(l10n.historyHowItRan, style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            _Fact(
              label: l10n.historyOpened,
              value: l10n.historyOpenedFor(
                DateFormat.Hm().format(basket.openedAt.toLocal()),
                basket.closesAt.difference(basket.openedAt).inMinutes,
              ),
            ),
            _Fact(label: l10n.historyPriced, value: l10n.historyNothing),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: OpenBasketText.money(theme.textTheme.bodyLarge!.color!),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Row(
        children: [
          if (member != null) ...[
            MemberInitial(member: member!),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              member?.displayName ?? '',
              style: theme.textTheme.titleMedium,
            ),
          ),
          Text(
            total,
            style: OpenBasketText.money(
              theme.textTheme.bodySmall!.color!,
            ).copyWith(fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class _ItemLine extends StatelessWidget {
  const _ItemLine({
    required this.item,
    this.trailing,
    this.subtitle,
    this.dropped = false,
  });

  final BasketItem item;
  final String? trailing;
  final String? subtitle;
  final bool dropped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall!.color!;
    final gone = dropped || item.status == ItemStatus.unavailable;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.name} ×${item.quantity}',
                  style: gone
                      ? OpenBasketText.item(
                          muted,
                        ).copyWith(decoration: TextDecoration.lineThrough)
                      : OpenBasketText.item(theme.textTheme.bodyLarge!.color!),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: OpenBasketText.meta(muted)),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: gone
                  ? OpenBasketText.meta(muted)
                  : OpenBasketText.money(theme.textTheme.bodyLarge!.color!),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
