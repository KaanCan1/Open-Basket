import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/formatters.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
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
    final ob = Ob.of(context);
    final history = ref.watch(historyProvider);

    return ObScaffold(
      body: RefreshIndicator(
        color: ob.onGround,
        onRefresh: () => ref.refresh(historyProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
          children: [
            Text(l10n.historyTitle, style: OpenBasketText.display(ob.onGround)),
            const SizedBox(height: 6),
            ...switch (history) {
              AsyncData(:final value) when value.isEmpty => [
                const SizedBox(height: 16),
                EmptyState(
                  title: l10n.historyEmptyTitle,
                  body: l10n.historyEmptyBody,
                ),
              ],
              AsyncData(:final value) => [
                _Summary(runs: value),
                const SizedBox(height: 16),
                for (final run in value) _RunRow(run: run),
              ],
              AsyncError() => [
                const SizedBox(height: 16),
                ErrorCard(
                  title: l10n.commonOffline,
                  body: l10n.commonOfflineRetryNote,
                  retryLabel: l10n.commonRetry,
                  onRetry: () => ref.invalidate(historyProvider),
                ),
              ],
              _ => [const SizedBox(height: 16), const SkeletonList()],
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

/// "today", "yesterday", "Sunday", "3 Sep" — the day alone, for the home
/// screen's recent runs.
String describeDay(AppLocalizations l10n, DateTime when, DateTime now) {
  final local = when.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final daysAgo = today.difference(day).inDays;
  if (daysAgo == 0) return l10n.dayToday;
  if (daysAgo == 1) return l10n.dayYesterday;
  return daysAgo < 7
      ? DateFormat.EEEE().format(local)
      : DateFormat.MMMd().format(local);
}

/// "14 runs · ₺3,182.40 through the house", the amount in mono.
class _Summary extends StatelessWidget {
  const _Summary({required this.runs});

  final List<PastRun> runs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final amount = MoneyFormat.format(
      runs.fold(0, (sum, r) => sum + r.totalMinor),
      runs.first.basket.currencyCode,
    );
    final whole = l10n.historySummary(runs.length, amount);
    final at = whole.indexOf(amount);
    final style = OpenBasketText.body(ob.meta).copyWith(fontSize: 14);
    if (at < 0) return Text(whole, style: style);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: whole.substring(0, at)),
          TextSpan(
            text: amount,
            style: OpenBasketText.mono(color: ob.onGround, fontSize: 14),
          ),
          TextSpan(text: whole.substring(at + amount.length)),
        ],
      ),
    );
  }
}

class _RunRow extends ConsumerWidget {
  const _RunRow({required this.run});

  final PastRun run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final basket = run.basket;
    final members = ref.watch(membersProvider).value ?? const [];
    final stores = ref.watch(storesProvider).value ?? const <Store>[];
    final store = stores.where((s) => s.id == basket.storeId).firstOrNull;
    final shopper = members
        .where((m) => m.id == basket.shopperMemberId)
        .firstOrNull;
    final settled = basket.status == BasketStatus.settled;
    final strong = settled ? ob.onGround : ob.meta;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store?.name ?? l10n.historyNoStore,
                    style: OpenBasketText.title(strong),
                  ),
                  Text(
                    l10n.historyWhen(
                      describeWhen(l10n, basket.openedAt, DateTime.now()),
                      shopper?.displayName ?? '',
                    ),
                    style: OpenBasketText.meta(ob.meta),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  settled
                      ? MoneyFormat.format(run.totalMinor, basket.currencyCode)
                      : l10n.runNoTotal,
                  style: OpenBasketText.money(strong).copyWith(fontSize: 16),
                ),
                Text(
                  (settled ? l10n.historySettled : l10n.historyCancelled)
                      .toUpperCase(),
                  style: OpenBasketText.label(
                    ob.meta,
                  ).copyWith(fontSize: 10, letterSpacing: 1.2),
                ),
              ],
            ),
          ],
        ),
        if (settled && run.itemsByMember.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final member in members)
                if (run.itemsByMember[member.id] != null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(4, 4, 9, 4),
                    decoration: BoxDecoration(
                      color: ob.tonal,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MemberInitial(member: member, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${run.itemsByMember[member.id]}',
                          style: OpenBasketText.mono(
                            color: ob.onGround,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ],
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('${Routes.history}/${basket.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: ob.rule)),
        ),
        // A cancelled run carries a dashed rule down its left edge, as the
        // set draws it: no prices, no debts.
        child: settled
            ? body
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 2,
                      child: CustomPaint(painter: _DashedLine(color: ob.faint)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: body),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DashedLine extends CustomPainter {
  const _DashedLine({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (var y = 0.0; y < size.height; y += 7) {
      canvas.drawLine(Offset(1, y), Offset(1, y + 4), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLine old) => old.color != color;
}
