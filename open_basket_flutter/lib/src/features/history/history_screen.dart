import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/formatters.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../basket/checkout_screen.dart';
import '../household/household_controller.dart';
import '../stores/stores_controller.dart';
import 'history_controller.dart';

/// Screen 16. Every finished run, newest first: where, when, who shopped,
/// what it cost, and who asked for how much.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(historyProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            Text(l10n.historyTitle, style: theme.textTheme.displayLarge),
            const SizedBox(height: 4),
            ...switch (history) {
              AsyncData(:final value) when value.isEmpty => [
                const SizedBox(height: 12),
                Text(l10n.historyEmpty, style: theme.textTheme.bodySmall),
              ],
              AsyncData(:final value) => [
                Text(
                  l10n.historySummary(
                    value.length,
                    MoneyFormat.format(
                      value.fold(0, (sum, r) => sum + r.totalMinor),
                      value.first.basket.currencyCode,
                    ),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                for (final run in value) _RunRow(run: run),
              ],
              AsyncError() => [
                const SizedBox(height: 12),
                Text(l10n.commonOffline, style: theme.textTheme.bodySmall),
              ],
              _ => [
                const SizedBox(height: 40),
                const Center(child: CircularProgressIndicator()),
              ],
            },
          ],
        ),
      ),
    );
  }
}

/// "Today, 18:29", "Yesterday, 09:10", "Sunday, 11:04", "3 Sep, 18:40".
String describeWhen(AppLocalizations l10n, DateTime when, DateTime now) {
  final local = when.toLocal();
  final time = DateFormat.Hm().format(local);
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final daysAgo = today.difference(day).inDays;
  if (daysAgo == 0) return l10n.historyToday(time);
  if (daysAgo == 1) return l10n.historyYesterday(time);
  final label = daysAgo < 7
      ? DateFormat.EEEE().format(local)
      : DateFormat.MMMd().format(local);
  return l10n.historyDayAndTime(label, time);
}

class _RunRow extends ConsumerWidget {
  const _RunRow({required this.run});

  final PastRun run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final basket = run.basket;
    final members = ref.watch(membersProvider).value ?? const [];
    final stores = ref.watch(storesProvider).value ?? const <Store>[];
    final store = stores.where((s) => s.id == basket.storeId).firstOrNull;
    final shopper = members
        .where((m) => m.id == basket.shopperMemberId)
        .firstOrNull;
    final settled = basket.status == BasketStatus.settled;
    final muted = theme.textTheme.bodySmall!.color!;

    return InkWell(
      onTap: () => context.push('${Routes.history}/${basket.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    store?.name ?? l10n.historyNoStore,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  MoneyFormat.format(run.totalMinor, basket.currencyCode),
                  style: OpenBasketText.money(
                    settled ? theme.textTheme.bodyLarge!.color! : muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.historyWhen(
                      describeWhen(l10n, basket.openedAt, DateTime.now()),
                      shopper?.displayName ?? '',
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  settled ? l10n.historySettled : l10n.historyCancelled,
                  style: OpenBasketText.meta(muted),
                ),
              ],
            ),
            if (run.itemsByMember.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  for (final member in members)
                    if (run.itemsByMember[member.id] != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            // A cancelled run's requests were dropped: the
                            // chips stay, greyed, so it still says who asked.
                            opacity: settled ? 1 : 0.5,
                            child: MemberInitial(member: member, size: 18),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${run.itemsByMember[member.id]}',
                            style: OpenBasketText.meta(muted),
                          ),
                        ],
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
