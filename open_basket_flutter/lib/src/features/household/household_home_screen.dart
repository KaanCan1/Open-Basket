import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/client_provider.dart';
import '../../core/formatters.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../basket/basket_controller.dart';
import '../basket/open_basket_sheet.dart';
import '../../../l10n/app_localizations.dart';
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (final error, final _) => Scaffold(
        body: _Retry(
          message: l10n.commonOffline,
          onRetry: () => ref.invalidate(myHouseholdProvider),
        ),
      ),
      data: (final it) =>
          it == null ? const CreateOrJoinScreen() : _Home(household: it),
    );
  }
}

class _Home extends ConsumerWidget {
  const _Home({required this.household});

  final Household household;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final members = ref.watch(membersProvider);
    final me = ref.watch(myMembershipProvider).value;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myHouseholdProvider);
            // The basket too: pulling down is what someone does when a
            // basket they were told about is not on the screen.
            ref.invalidate(activeBasketProvider);
            ref.invalidate(lastSettledRunProvider);
            await ref.read(membersProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 32),
              Text(household.name, style: theme.textTheme.displayLarge),
              const SizedBox(height: 4),
              Text(
                l10n.homeMembersOne(members.value?.length ?? 0),
                style: OpenBasketText.meta(theme.textTheme.bodySmall!.color!),
              ),
              const SizedBox(height: 28),
              const _BasketSection(),
              const SizedBox(height: 32),
              const _StoresRow(),
              const SizedBox(height: 24),
              _CodeCard(code: household.code),
              const SizedBox(height: 32),
              Text(l10n.homeMembersTitle, style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              ...?members.value?.map(
                (final member) => _MemberRow(
                  member: member,
                  isYou: member.id == me?.id,
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: ref.watch(signOutProvider),
                child: Text(l10n.homeSignOut),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// The join code, big enough to read out across a room, and copyable.
class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall!.color!;

    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: code));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeCodeCopied)),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.homeCodeLabel, style: theme.textTheme.labelSmall),
            const SizedBox(height: 12),
            Text(
              code,
              style: OpenBasketText.countdown(
                theme.textTheme.bodyLarge!.color!,
              ).copyWith(fontSize: 34, letterSpacing: 8),
            ),
            const SizedBox(height: 8),
            Text(l10n.homeCodeNote, style: OpenBasketText.meta(muted)),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.isYou});

  final HouseholdMember member;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tone = MemberTones.forMember(
      member.id ?? 0,
      theme.brightness,
    );

    return Container(
      constraints: const BoxConstraints(minHeight: kMinTapTarget),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: tone),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.displayName,
              style: OpenBasketText.item(theme.textTheme.bodyLarge!.color!),
            ),
          ),
          if (isYou) _Tag(text: l10n.homeYouTag),
          if (member.role == MemberRole.owner) ...[
            const SizedBox(width: 6),
            _Tag(text: l10n.homeOwnerTag),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(text, style: theme.textTheme.labelSmall),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: theme.textTheme.displayLarge),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
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
    final theme = Theme.of(context);
    final active = ref.watch(activeBasketProvider);
    final members = ref.watch(membersProvider).value ?? const [];

    final openButton = FilledButton(
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
      child: Text(l10n.homeOpenBasket),
    );

    final basket = active.value;
    if (basket == null) {
      final lastRun = ref.watch(lastSettledRunProvider).value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lastRun != null) ...[
            _LastRunCard(basket: lastRun.basket, lines: lastRun.lines),
            const SizedBox(height: 28),
          ],
          Text(l10n.homeNoBasket, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.homeNoBasketNote, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          openButton,
        ],
      );
    }

    final shopper = members
        .where((final m) => m.id == basket.shopperMemberId)
        .map((final m) => m.displayName)
        .firstOrNull;
    final open = basket.status == BasketStatus.open;
    final store = (ref.watch(storesProvider).value ?? const <Store>[])
        .where((s) => s.id == basket.storeId)
        .firstOrNull
        ?.name;

    final card = Container(
      padding: const EdgeInsets.all(20),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            open ? l10n.homeBasketOpenTitle : l10n.homeBasketFrozenTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            open
                ? (store == null
                      ? l10n.homeBasketOpenNote(shopper ?? '')
                      : l10n.homeBasketOpenAt(shopper ?? '', store))
                : l10n.homeBasketFrozenNote(shopper ?? ''),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push('${Routes.basket}/${basket.id}'),
            child: Text(l10n.homeBasketSee),
          ),
        ],
      ),
    );

    // A frozen basket is waiting for prices, not blocking the next run.
    // Rule 4 is one *open* basket, so the way to start another stays on
    // screen underneath it.
    if (open) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [card, const SizedBox(height: 16), openButton],
    );
  }
}

/// The last run, settled: what this member owes or is owed, and the way to
/// the full settlement. Without it a member who was not watching the live
/// basket had no way to find out (ADR-031).
class _LastRunCard extends ConsumerWidget {
  const _LastRunCard({required this.basket, required this.lines});

  final Basket basket;
  final List<SettlementLine> lines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final me = ref.watch(myMembershipProvider).value;
    final members = ref.watch(membersProvider).value ?? const [];
    String name(int id) =>
        members.where((m) => m.id == id).firstOrNull?.displayName ?? '';
    String money(int minor) => MoneyFormat.format(minor, basket.currencyCode);

    final iOwe = lines.where((l) => l.fromMemberId == me?.id).toList();
    final owedToMe = lines.where((l) => l.toMemberId == me?.id).toList();
    final String summary;
    if (iOwe.isNotEmpty) {
      summary = iOwe
          .map(
            (l) => l10n.homeLastRunYouOwe(
              name(l.toMemberId),
              money(l.amountMinor),
            ),
          )
          .join('\n');
    } else if (owedToMe.length == 1) {
      summary = l10n.homeLastRunOwesYou(
        name(owedToMe.single.fromMemberId),
        money(owedToMe.single.amountMinor),
      );
    } else if (owedToMe.length > 1) {
      summary = l10n.homeLastRunManyOweYou(
        owedToMe.length,
        money(owedToMe.fold(0, (sum, l) => sum + l.amountMinor)),
      );
    } else {
      summary = l10n.homeLastRunClear;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.homeLastRunTitle, style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(summary, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () =>
                context.push('${Routes.basket}/${basket.id}/settlement'),
            child: Text(l10n.liveBasketSeeSettlement),
          ),
        ],
      ),
    );
  }
}

/// Where the stores live until there is a settings screen (screen 19 has a
/// "Stores" row; this is that row, on the home screen for now).
class _StoresRow extends ConsumerWidget {
  const _StoresRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stores = ref.watch(storesProvider).value ?? const <Store>[];

    return InkWell(
      onTap: () => context.push(Routes.stores),
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinTapTarget),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.dividerColor),
            bottom: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.homeStoresLabel, style: theme.textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Text(
                    stores.isEmpty
                        ? l10n.homeStoresNone
                        : stores.map((s) => s.name).join(', '),
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: theme.textTheme.bodySmall!.color,
            ),
          ],
        ),
      ),
    );
  }
}
