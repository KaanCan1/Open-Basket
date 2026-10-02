import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/formatters.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../basket/basket_controller.dart';
import '../basket/countdown_banner.dart';
import '../basket/open_basket_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../history/history_controller.dart';
import '../history/history_screen.dart';
import '../stores/stores_controller.dart';
import 'create_or_join_screen.dart';
import 'household_controller.dart';

/// Screen 05. The signed-in home.
///
/// Resolves the household here rather than in the router's redirect: the
/// redirect has to stay synchronous, and a future in it would either block the
/// first frame or flash the wrong screen. So this screen owns the three
/// states — loading, no household, a household — and the router only ever asks
/// "signed in or not".
class HouseholdHomeScreen extends ConsumerStatefulWidget {
  const HouseholdHomeScreen({super.key});

  @override
  ConsumerState<HouseholdHomeScreen> createState() =>
      _HouseholdHomeScreenState();
}

class _HouseholdHomeScreenState extends ConsumerState<HouseholdHomeScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Everything on this screen is fetched once. Coming back to the app is
    // when it is most likely to be stale — someone joined, a basket opened
    // or closed — so that is when it refetches, without anyone having to
    // know that pulling down refreshes.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        ref.invalidate(myHouseholdProvider);
        ref.invalidate(activeBasketProvider);
        ref.invalidate(lastSettledRunProvider);
        ref.invalidate(historyProvider);
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final household = ref.watch(myHouseholdProvider);

    return household.when(
      loading: () => const SkeletonScreen(),
      error: (final error, final _) => ObScaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ErrorCard(
              title: l10n.commonOffline,
              body: l10n.commonOfflineRetryNote,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(myHouseholdProvider),
            ),
          ),
        ),
      ),
      data: (final it) =>
          it == null ? const CreateOrJoinScreen() : _Home(household: it),
    );
  }
}

/// Opens a screen that shows the household's code or members, refetching
/// them first: the owner may have rotated the code on another phone since
/// this one last asked, and settings showed the dead code until a restart.
void _pushFresh(BuildContext context, WidgetRef ref, String route) {
  ref.invalidate(myHouseholdProvider);
  context.push(route);
}

class _Home extends ConsumerWidget {
  const _Home({required this.household});

  final Household household;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final members = ref.watch(activeMembersProvider).value ?? const [];

    return ObScaffold(
      body: RefreshIndicator(
        color: ob.onGround,
        onRefresh: () async {
          ref.invalidate(myHouseholdProvider);
          // The basket too: pulling down is what someone does when a basket
          // they were told about is not on the screen.
          ref.invalidate(activeBasketProvider);
          ref.invalidate(lastSettledRunProvider);
          ref.invalidate(historyProvider);
          await ref.read(membersProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Row(
              children: [
                const Wordmark(),
                const Spacer(),
                GlassIconButton(
                  icon: CupertinoIcons.gear,
                  tooltip: l10n.settingsTitle,
                  onTap: () => _pushFresh(context, ref, Routes.settings),
                ),
              ],
            ),
            const SizedBox(height: 26),
            SectionLabel(l10n.homeHouseholdLabel),
            Text(
              household.name,
              style: OpenBasketText.display(ob.onGround),
            ),
            const SizedBox(height: 26),
            const _BasketSection(),
            const SizedBox(height: 26),
            SectionLabel(
              l10n.homeMembersTitle,
              action: l10n.homeInvite,
              onAction: () => _pushFresh(context, ref, Routes.members),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final member in members)
                  PersonChip(
                    memberId: member.id ?? 0,
                    name: member.displayName,
                    onTap: () => _pushFresh(context, ref, Routes.members),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            const _RecentRuns(),
          ],
        ),
      ),
    );
  }
}

/// The basket, or the way to open one. The first thing on the home screen
/// because it is the only thing anyone opens the app to do.
class _BasketSection extends ConsumerWidget {
  const _BasketSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final active = ref.watch(activeBasketProvider);
    final members = ref.watch(membersProvider).value ?? const [];
    final me = ref.watch(myMembershipProvider).value;

    final openButton = PrimaryButton(
      label: l10n.homeOpenBasket,
      icon: CupertinoIcons.add,
      glow: true,
      onPressed: () async {
        final opened = await OpenBasketSheet.show(context);
        if (opened == null || !context.mounted) return;
        // Someone else's run means the sheet lost the race (screen 24): say
        // so on arrival rather than dropping them in without a word.
        final me = ref.read(myMembershipProvider).value;
        final joined = me != null && opened.shopperMemberId != me.id;
        context.push(
          '${Routes.basket}/${opened.id}${joined ? '?joined=1' : ''}',
        );
      },
    );

    final basket = active.value;
    if (basket == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _IdleCard(),
          const SizedBox(height: 14),
          openButton,
          const SizedBox(height: 14),
          Text(
            l10n.homeOpenBasketNote,
            textAlign: TextAlign.center,
            style: OpenBasketText.meta(ob.meta),
          ),
        ],
      );
    }

    final shopper = members
        .where((final m) => m.id == basket.shopperMemberId)
        .map((final m) => m.displayName)
        .firstOrNull;
    final store = (ref.watch(storesProvider).value ?? const <Store>[])
        .where((s) => s.id == basket.storeId)
        .firstOrNull
        ?.name;
    void see() => context.push('${Routes.basket}/${basket.id}');

    if (basket.status == BasketStatus.open) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: see,
            child: CountdownBanner(
              basket: basket,
              margin: EdgeInsets.zero,
              shopperName: shopper ?? '',
              storeName: store,
              isShopper: me != null && basket.shopperMemberId == me.id,
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: l10n.homeBasketSee, onPressed: see),
        ],
      );
    }

    // A frozen basket is waiting for prices, not blocking the next run.
    // Rule 4 is one *open* basket, so the way to start another stays on
    // screen underneath it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: see,
          child: Glass(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(CupertinoIcons.lock, size: 24, color: ob.onGround),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeBasketFrozenTitle,
                        style: OpenBasketText.title(ob.onGround),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.homeBasketFrozenNote(shopper ?? ''),
                        style: OpenBasketText.meta(ob.meta),
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right, size: 16, color: ob.meta),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        openButton,
      ],
    );
  }
}

/// "No basket open · Last run today · ₺250.80", and — until the next run —
/// what this member owes or is owed from it. Without that line a member who
/// was not watching the live basket had no way to find out (ADR-031).
class _IdleCard extends ConsumerWidget {
  const _IdleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final runs = ref.watch(historyProvider).value ?? const <PastRun>[];
    // A cancelled run cost nothing and says nothing about the last shop.
    final last = runs
        .where((r) => r.basket.status == BasketStatus.settled)
        .firstOrNull;
    final lastSettled = ref.watch(lastSettledRunProvider).value;
    final me = ref.watch(myMembershipProvider).value;
    final members = ref.watch(membersProvider).value ?? const [];
    String name(int id) =>
        members.where((m) => m.id == id).firstOrNull?.displayName ?? '';

    String? owes;
    if (lastSettled != null && me != null) {
      String money(int minor) =>
          MoneyFormat.format(minor, lastSettled.basket.currencyCode);
      final lines = lastSettled.lines;
      final iOwe = lines.where((l) => l.fromMemberId == me.id).toList();
      final owedToMe = lines.where((l) => l.toMemberId == me.id).toList();
      if (iOwe.isNotEmpty) {
        owes = iOwe
            .map(
              (l) => l10n.homeLastRunYouOwe(
                name(l.toMemberId),
                money(l.amountMinor),
              ),
            )
            .join('\n');
      } else if (owedToMe.length == 1) {
        owes = l10n.homeLastRunOwesYou(
          name(owedToMe.single.fromMemberId),
          money(owedToMe.single.amountMinor),
        );
      } else if (owedToMe.length > 1) {
        owes = l10n.homeLastRunManyOweYou(
          owedToMe.length,
          money(owedToMe.fold(0, (sum, l) => sum + l.amountMinor)),
        );
      }
    }

    final card = Glass(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const BrandMark(height: 30, opacity: 0.85),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeNoBasketTitle,
                  style: OpenBasketText.title(ob.onGround),
                ),
                const SizedBox(height: 2),
                if (last == null)
                  Text(
                    l10n.homeNoRunsYet,
                    style: OpenBasketText.meta(ob.meta),
                  )
                else
                  _LastRunLine(run: last),
                if (owes != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    owes,
                    style: OpenBasketText.meta(
                      ob.onGround,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
          if (lastSettled != null)
            Icon(CupertinoIcons.chevron_right, size: 16, color: ob.meta),
        ],
      ),
    );
    if (lastSettled == null) return card;
    return GestureDetector(
      onTap: () => context.push(
        '${Routes.basket}/${lastSettled.basket.id}/settlement',
      ),
      child: card,
    );
  }
}

class _LastRunLine extends StatelessWidget {
  const _LastRunLine({required this.run});

  final PastRun run;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final day = describeDay(l10n, run.basket.openedAt, DateTime.now());
    final amount = MoneyFormat.format(run.totalMinor, run.basket.currencyCode);
    final whole = l10n.homeLastRunLine(day, amount);
    final at = whole.lastIndexOf(amount);
    final style = OpenBasketText.meta(ob.meta);
    if (at < 0) return Text(whole, style: style);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: whole.substring(0, at)),
          TextSpan(
            text: amount,
            style: OpenBasketText.mono(color: ob.meta, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Screen 05's last two runs, and the way to all of them.
class _RecentRuns extends ConsumerWidget {
  const _RecentRuns();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final runs = ref.watch(historyProvider).value ?? const <PastRun>[];
    if (runs.isEmpty) return const SizedBox.shrink();
    final stores = ref.watch(storesProvider).value ?? const <Store>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(
          l10n.homeRecentRuns,
          action: l10n.homeAllRuns,
          onAction: () => context.push(Routes.history),
        ),
        const SizedBox(height: 6),
        for (final run in runs.take(2))
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('${Routes.history}/${run.basket.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: ob.rule)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeRecentRunTitle(
                            stores
                                    .where((s) => s.id == run.basket.storeId)
                                    .firstOrNull
                                    ?.name ??
                                l10n.historyNoStore,
                            describeDay(
                              l10n,
                              run.basket.openedAt,
                              DateTime.now(),
                            ),
                          ),
                          style: OpenBasketText.body(
                            ob.onGround,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          l10n.homeRecentRunMeta(
                            run.itemCount,
                            run.basket.status == BasketStatus.cancelled
                                ? l10n.runCancelledLower
                                : l10n.runSettledLower,
                          ),
                          style: OpenBasketText.meta(ob.meta),
                        ),
                      ],
                    ),
                  ),
                  // A cancelled run was never priced: a dash, not ₺0.00.
                  Text(
                    run.basket.status == BasketStatus.cancelled
                        ? l10n.runNoTotal
                        : MoneyFormat.format(
                            run.totalMinor,
                            run.basket.currencyCode,
                          ),
                    style: OpenBasketText.money(
                      run.basket.status == BasketStatus.cancelled
                          ? ob.meta
                          : ob.onGround,
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
