import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../basket/checkout_screen.dart';
import 'household_controller.dart';
import 'rotate_code_screen.dart';

/// Screen 17. Who is in the house, and the one way in: the code, with a
/// share button, and — for the owner — a way to change it (screen 18).
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final household = ref.watch(myHouseholdProvider).value;
    final me = ref.watch(myMembershipProvider).value;
    final members = ref.watch(activeMembersProvider).value ?? const [];
    final isOwner = me?.role == MemberRole.owner;

    if (household == null) return const SkeletonScreen();
    const paper = OpenBasketColors.paper;

    return ObScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          SectionLabel(l10n.membersLabel),
          Text(household.name, style: OpenBasketText.display(ob.onGround)),
          const SizedBox(height: 20),
          InkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.membersCodeLabel,
                        style: OpenBasketText.label(OpenBasketColors.metaDark),
                      ),
                    ),
                    // Signal as text is only ever on ink (16.6:1).
                    Text(
                      l10n.membersPermanent,
                      style: OpenBasketText.label(
                        OpenBasketColors.signal,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CodeBoxes(code: household.code),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (final buttonContext) => FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: OpenBasketText.title(
                              OpenBasketColors.ink,
                              fontSize: 15,
                            ),
                          ),
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
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: l10n.membersCopy,
                      child: GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: household.code),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.homeCodeCopied)),
                          );
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: paper.withValues(alpha: 0.24),
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.doc_on_doc,
                            size: 18,
                            color: paper,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isOwner
                            ? l10n.membersCodeNote
                            : l10n.membersRotateOwnerOnly,
                        style: OpenBasketText.meta(
                          OpenBasketColors.metaDark,
                        ).copyWith(fontSize: 12),
                      ),
                    ),
                    if (isOwner)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => RotateCodeScreen.show(context),
                        child: SizedBox(
                          height: kMinTapTarget,
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              l10n.membersRotate,
                              style: OpenBasketText.body(paper).copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: paper,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionLabel(l10n.membersCount(members.length)),
          const SizedBox(height: 6),
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

/// The code as six boxes on the ink card, big enough to read out across a
/// room.
class CodeBoxes extends StatelessWidget {
  const CodeBoxes({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) =>
      CharBoxes(value: code, focused: false, onInk: true);
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.isYou});

  final HouseholdMember member;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final joined = describeJoined(member.joinedAt, DateTime.now());
    final line = member.role == MemberRole.owner
        ? l10n.membersOwnerJoined(joined.when, joined.month)
        : l10n.membersJoined(joined.when, joined.month);

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: ob.rule)),
      ),
      child: Row(
        children: [
          MemberInitial(member: member, size: 38),
          const SizedBox(width: 14),
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
                          style: OpenBasketText.meta(
                            ob.meta,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  style: OpenBasketText.item(ob.onGround),
                ),
                Text(line, style: OpenBasketText.meta(ob.meta)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
