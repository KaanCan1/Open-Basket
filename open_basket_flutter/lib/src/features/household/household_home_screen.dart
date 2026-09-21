import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/client_provider.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../basket/basket_controller.dart';
import '../basket/open_basket_sheet.dart';
import '../../../l10n/app_localizations.dart';
import 'create_or_join_screen.dart';
import 'household_controller.dart';

/// Screen 05. The signed-in home.
///
/// Resolves the household here rather than in the router's redirect: the
/// redirect has to stay synchronous, and a future in it would either block the
/// first frame or flash the wrong screen. So this screen owns the three
/// states — loading, no household, a household — and the router only ever asks
/// "signed in or not".
class HouseholdHomeScreen extends ConsumerWidget {
  const HouseholdHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final basket = active.value;
    if (basket == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.homeNoBasket, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.homeNoBasketNote, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              final opened = await OpenBasketSheet.show(context);
              if (opened == null || !context.mounted) return;
              context.push('${Routes.basket}/${opened.id}');
            },
            child: Text(l10n.homeOpenBasket),
          ),
        ],
      );
    }

    final shopper = members
        .where((final m) => m.id == basket.shopperMemberId)
        .map((final m) => m.displayName)
        .firstOrNull;
    final open = basket.status == BasketStatus.open;

    return Container(
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
                ? l10n.homeBasketOpenNote(shopper ?? '')
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
  }
}
