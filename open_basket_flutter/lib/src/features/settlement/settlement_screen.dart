import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/formatters.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../history/history_screen.dart';
import '../stores/stores_controller.dart';
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
    final ob = Ob.of(context);
    final lines = ref.watch(settlementProvider(basketId));
    final live = ref.watch(liveBasketProvider(basketId));
    final members = ref.watch(membersProvider).value ?? const [];
    final basket = live.basket;

    if (basket == null || !lines.hasValue) return const SkeletonScreen();

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
    final count =
        ref.watch(activeMembersProvider).value?.length ?? members.length;
    // Display only, the same truncating division the server uses (rule 6).
    final each = count == 0 ? 0 : gap ~/ count;
    String money(int minor) => MoneyFormat.format(minor, currency);

    HouseholdMember? member(int id) =>
        members.where((m) => m.id == id).firstOrNull;
    String name(int id) => member(id)?.displayName ?? '';
    final shopper = name(basket.shopperMemberId);
    final store = (ref.watch(storesProvider).value ?? const <Store>[])
        .where((s) => s.id == basket.storeId)
        .firstOrNull
        ?.name;
    final day = describeDay(l10n, basket.openedAt, DateTime.now());
    final title = store == null
        ? l10n.settlementRunTitlePlain(day)
        : l10n.settlementRunTitle(store, day);

    final summary = [
      l10n.settlementShareHeader(title, money(receipt)),
      for (final line in lines.value!)
        l10n.settlementShareLine(
          name(line.fromMemberId),
          name(line.toMemberId),
          money(line.amountMinor),
        ),
    ].join('\n');

    return ObScaffold(
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lines.value!.isNotEmpty) ...[
            Builder(
              builder: (buttonContext) => PrimaryButton(
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
            ),
            SizedBox(
              height: 28,
              child: Center(
                child: Text(
                  l10n.settlementShareNote,
                  style: OpenBasketText.meta(ob.meta).copyWith(fontSize: 12),
                ),
              ),
            ),
          ] else
            PrimaryButton(
              label: l10n.settlementDone,
              onPressed: () => context.go(Routes.home),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Row(
            children: [
              Tag(l10n.settlementBadge, icon: CupertinoIcons.checkmark_alt),
              const Spacer(),
              LinkText(
                l10n.settlementDone,
                fontSize: 14,
                onTap: () => context.go(Routes.home),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ScreenTitle(
            title,
            subtitle: l10n.settlementSummary(
              l10n.checkoutItems(items.length),
              unavailable,
              money(receipt),
            ),
          ),
          const SizedBox(height: 22),
          SectionLabel(l10n.settlementWhoOwes),
          const SizedBox(height: 8),
          if (lines.value!.isEmpty)
            _Nobody()
          else
            for (final line in lines.value!) ...[
              _Line(
                line: line,
                from: member(line.fromMemberId),
                to: name(line.toMemberId),
                currency: currency,
              ),
              const SizedBox(height: 10),
            ],
          if (gap != 0) ...[
            const SizedBox(height: 12),
            TonalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionLabel(l10n.settlementGapTitle),
                  const SizedBox(height: 4),
                  _Figure(
                    label: l10n.settlementItemsPriced,
                    value: money(itemSum),
                  ),
                  _Figure(label: l10n.settlementReceipt, value: money(receipt)),
                  Divider(height: 16, color: ob.faint),
                  _Figure(
                    label: l10n.settlementGapAcross(money(gap), count),
                    value: l10n.settlementEach(money(each)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.settlementShopperCarries(shopper),
                    style: OpenBasketText.meta(ob.meta).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.settlementPaid(shopper),
                  style: OpenBasketText.body(ob.meta).copyWith(fontSize: 14),
                ),
              ),
              Text(
                money(receipt),
                style: OpenBasketText.money(ob.onGround).copyWith(fontSize: 18),
              ),
            ],
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
    final ob = Ob.of(context);
    final ink = ob.onGround;
    final items = MoneyFormat.format(line.itemsMinor, currency);
    final gap = line.receiptGapMinor;

    return Glass(
      radius: 18,
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          if (from != null) MemberInitial(member: from!, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settlementOwes(from?.displayName ?? '', to),
                  style: OpenBasketText.title(ink),
                ),
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
                  style: OpenBasketText.meta(ob.meta),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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

class _Nobody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    return TonalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settlementNobody, style: OpenBasketText.title(ob.onGround)),
          const SizedBox(height: 4),
          Text(l10n.settlementNobodyNote, style: OpenBasketText.meta(ob.meta)),
        ],
      ),
    );
  }
}
