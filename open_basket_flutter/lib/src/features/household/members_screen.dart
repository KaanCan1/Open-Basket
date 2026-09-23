import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../basket/checkout_screen.dart';
import 'household_controller.dart';

/// Screen 17. Who is in the house, and the one way in: the code, with a
/// share button, and — for the owner — a way to change it (screen 18).
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final household = ref.watch(myHouseholdProvider).value;
    final me = ref.watch(myMembershipProvider).value;
    final members = ref.watch(activeMembersProvider).value ?? const [];
    final isOwner = me?.role == MemberRole.owner;

    if (household == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Text(l10n.membersLabel, style: theme.textTheme.labelSmall),
          const SizedBox(height: 6),
          Text(household.name, style: theme.textTheme.displayLarge),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(l10n.membersCodeLabel, style: theme.textTheme.labelSmall),
              const Spacer(),
              _Tag(text: l10n.membersPermanent),
            ],
          ),
          const SizedBox(height: 12),
          CodeBoxes(code: household.code),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (final buttonContext) => FilledButton.icon(
                    onPressed: () => shareHouseholdCode(
                      buttonContext,
                      household.name,
                      household.code,
                    ),
                    icon: const Icon(CupertinoIcons.share, size: 18),
                    label: Text(l10n.membersShare),
                  ),
                ),
              ),
              if (isOwner) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push(Routes.rotateCode),
                    child: Text(l10n.membersRotate),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isOwner ? l10n.membersCodeNote : l10n.membersRotateOwnerOnly,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.membersCount(members.length),
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          for (final member in members)
            _MemberRow(member: member, isYou: member.id == me?.id),
        ],
      ),
    );
  }
}

/// Opens the phone's share sheet with the code and where to get the app.
/// The anchor rectangle is what an iPad needs to place its popover.
Future<void> shareHouseholdCode(
  BuildContext context,
  String household,
  String code,
) async {
  final l10n = AppLocalizations.of(context);
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      text: l10n.membersShareText(household, code),
      subject: l10n.membersShareSubject(household),
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}

/// When someone joined, the way the design words it: this week, last week,
/// or the month — with the year once it is not this one.
({String when, String month}) describeJoined(DateTime joinedAt, DateTime now) {
  final local = joinedAt.toLocal();
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(local.year, local.month, local.day)).inDays;
  if (days < 7) return (when: 'thisWeek', month: '');
  if (days < 14) return (when: 'lastWeek', month: '');
  final month = local.year == now.year
      ? DateFormat.MMMM().format(local)
      : DateFormat.yMMMM().format(local);
  return (when: 'month', month: month);
}

/// The code as six boxes, big enough to read out across a room.
class CodeBoxes extends StatelessWidget {
  const CodeBoxes({required this.code, this.muted = false, super.key});

  final String code;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = muted
        ? theme.textTheme.bodySmall!.color!
        : theme.textTheme.bodyLarge!.color!;
    return Row(
      children: [
        for (var i = 0; i < code.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.86,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  code[i],
                  style: OpenBasketText.countdown(
                    ink,
                  ).copyWith(fontSize: 28, letterSpacing: 0),
                ),
              ),
            ),
          ),
        ],
      ],
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
    final joined = describeJoined(member.joinedAt, DateTime.now());
    final line = member.role == MemberRole.owner
        ? l10n.membersOwnerJoined(joined.when, joined.month)
        : l10n.membersJoined(joined.when, joined.month);

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          MemberInitial(member: member, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: member.displayName),
                      if (isYou)
                        TextSpan(
                          text: ' ${l10n.membersYou}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(line, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
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
      decoration: BoxDecoration(border: Border.all(color: theme.dividerColor)),
      child: Text(text, style: theme.textTheme.labelSmall),
    );
  }
}
