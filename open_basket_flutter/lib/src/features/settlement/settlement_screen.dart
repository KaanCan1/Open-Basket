import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/formatters.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../basket/basket_controller.dart';
import '../basket/checkout_screen.dart';
import '../basket/live_basket_controller.dart';
import '../household/household_controller.dart';

/// Screen 15. Who owes whom, read-only, one line per debtor.
///
/// Everything on it comes from the server: the lines are the stored
/// `SettlementLine` rows (rule 6), and the basket and items come from the live
/// stream's snapshot, which a settled basket still answers with.
class SettlementScreen extends ConsumerWidget {
  const SettlementScreen({required this.basketId, super.key});

  final int basketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lines = ref.watch(settlementProvider(basketId));
    final live = ref.watch(liveBasketProvider(basketId));
    final members = ref.watch(membersProvider).value ?? const [];
    final basket = live.basket;

    if (basket == null || !lines.hasValue) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currency = basket.currencyCode;
    final items = live.items;
    final unavailable = items
        .where((i) => i.status == ItemStatus.unavailable)
        .length;
    final itemSum = items
        .where((i) => i.status == ItemStatus.picked && i.priceMinor != null)
        .fold<int>(0, (sum, i) => sum + i.priceMinor!);
    final receipt = basket.receiptTotalMinor ?? itemSum;
    final gap = receipt - itemSum;

    HouseholdMember? member(int id) =>
        members.where((m) => m.id == id).firstOrNull;
    String name(int id) => member(id)?.displayName ?? '';

    final summary = [
      for (final line in lines.value!)
        l10n.settlementShareLine(
          name(line.fromMemberId),
          name(line.toMemberId),
          MoneyFormat.format(line.amountMinor, currency),
        ),
    ].join('\n');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go(Routes.home),
            style: TextButton.styleFrom(minimumSize: const Size(64, 44)),
            child: Text(l10n.settlementDone),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.textTheme.bodyLarge!.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    size: 13,
                    color: theme.scaffoldBackgroundColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.settlementBadge,
                    style: OpenBasketText.label(theme.scaffoldBackgroundColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.settlementTitle,
            style: OpenBasketText.display(theme.textTheme.bodyLarge!.color!),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.settlementSummary(
              l10n.checkoutItems(items.length),
              unavailable,
              MoneyFormat.format(receipt, currency),
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 28),
          Text(l10n.settlementWhoOwes, style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          if (lines.value!.isEmpty)
            _Nobody()
          else
            for (final line in lines.value!)
              _Line(
                line: line,
                from: member(line.fromMemberId),
                to: name(line.toMemberId),
                currency: currency,
              ),
          if (gap != 0) ...[
            const SizedBox(height: 28),
            Text(l10n.settlementGapTitle, style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            _Figure(
              label: l10n.settlementItemsPriced,
              value: MoneyFormat.format(itemSum, currency),
            ),
            _Figure(
              label: l10n.settlementReceipt,
              value: MoneyFormat.format(receipt, currency),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.settlementGapAcross(
                MoneyFormat.format(gap, currency),
                members.length,
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 32),
          if (lines.value!.isNotEmpty)
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
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.line,
    required this.from,
    required this.to,
    required this.currency,
  });

  final SettlementLine line;
  final HouseholdMember? from;
  final String to;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ink = theme.textTheme.bodyLarge!.color!;
    final items = MoneyFormat.format(line.itemsMinor, currency);
    final gap = line.receiptGapMinor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          if (from != null) MemberInitial(member: from!, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settlementOwes(from?.displayName ?? '', to),
                  style: OpenBasketText.item(ink),
                ),
                const SizedBox(height: 2),
                Text(
                  gap >= 0
                      ? l10n.settlementBreakdown(
                          items,
                          MoneyFormat.format(gap, currency),
                        )
                      : l10n.settlementBreakdownCredit(
                          items,
                          MoneyFormat.format(-gap, currency),
                        ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            MoneyFormat.format(line.amountMinor, currency),
            style: OpenBasketText.money(ink).copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

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
          Text(
            value,
            style: OpenBasketText.money(theme.textTheme.bodyLarge!.color!),
          ),
        ],
      ),
    );
  }
}

class _Nobody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settlementNobody, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.settlementNobodyNote, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
