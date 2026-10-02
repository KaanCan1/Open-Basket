import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/client_provider.dart';
import '../../core/formatters.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../household/household_controller.dart';
import '../stores/stores_controller.dart';
import 'currency_screen.dart';
import '../../core/failure_message.dart';

/// Screen 19. The household's settings, and the way out.
///
/// The design's notification switches are left out until pushes exist
/// (Days 11-12): a switch that turns off nothing is a promise the app does
/// not keep.
final _versionProvider = FutureProvider<String>(
  (final ref) async => (await PackageInfo.fromPlatform()).version,
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// One text field in an alert; null when cancelled or left unchanged.
  static Future<String?> _askForName(
    BuildContext context, {
    required String title,
    required String current,
    required int maxLength,
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (final context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            maxLength: maxLength,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.itemMarkCancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.settingsRenameSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || name.trim() == current) {
      return null;
    }
    return name;
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    Household household,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askForName(
      context,
      title: l10n.settingsRenameTitle,
      current: household.name,
      maxLength: 60,
    );
    if (name == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(householdControllerProvider).rename(name);
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    }
  }

  Future<void> _nameMyself(
    BuildContext context,
    WidgetRef ref,
    HouseholdMember me,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askForName(
      context,
      title: l10n.settingsYourNameTitle,
      current: me.displayName,
      maxLength: 40,
    );
    if (name == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(householdControllerProvider).setMyName(name);
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    }
  }

  Future<void> _leave(
    BuildContext context,
    WidgetRef ref,
    Household household,
  ) async {
    final l10n = AppLocalizations.of(context);
    final leave = await showCupertinoDialog<bool>(
      context: context,
      builder: (final context) => CupertinoAlertDialog(
        title: Text(l10n.settingsLeaveConfirm(household.name)),
        content: Text(l10n.settingsLeaveConfirmNote),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.itemMarkCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settingsLeaveYes),
          ),
        ],
      ),
    );
    if (leave != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(householdControllerProvider).leave();
      router.go(Routes.home);
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final household = ref.watch(myHouseholdProvider).value;
    final me = ref.watch(myMembershipProvider).value;
    final members = ref.watch(activeMembersProvider).value ?? const [];
    final stores = ref.watch(storesProvider).value ?? const <Store>[];
    final isOwner = me?.role == MemberRole.owner;
    final version = ref.watch(_versionProvider).value;
    final email = ref.watch(myEmailProvider).value;

    if (household == null) return const SkeletonScreen(back: true);

    final currency = household.currencyCode;
    final ob = Ob.of(context);

    return ObScaffold(
      back: true,
      backLabel: l10n.settingsBack,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Text(l10n.settingsTitle, style: OpenBasketText.display(ob.onGround)),
          const SizedBox(height: 18),
          SectionLabel(l10n.settingsHousehold),
          const SizedBox(height: 4),
          ListRow(
            title: l10n.settingsName,
            value: household.name,
            chevron: isOwner,
            onTap: isOwner ? () => _rename(context, ref, household) : null,
          ),
          ListRow(
            title: l10n.settingsCurrency,
            subtitle:
                '${CurrencyScreen.nameOf(l10n, currency)} · '
                '${l10n.settingsCurrencyNote}',
            value: '${MoneyFormat.symbol(currency)} $currency',
            valueMono: true,
            onTap: () => context.push(Routes.currency),
          ),
          ListRow(
            title: l10n.settingsStores,
            subtitle: stores.isEmpty
                ? l10n.homeStoresNone
                : stores.map((s) => s.name).join(', '),
            onTap: () => context.push(Routes.stores),
          ),
          ListRow(
            title: l10n.settingsMembers,
            subtitle: l10n.settingsMembersValue(members.length, household.code),
            onTap: () => context.push(Routes.members),
          ),
          if (me != null)
            ListRow(
              title: l10n.settingsYourName,
              subtitle: l10n.settingsYourNameNote,
              value: me.displayName,
              onTap: () => _nameMyself(context, ref, me),
            ),
          if (!isOwner) ...[
            const SizedBox(height: 8),
            Text(l10n.settingsOwnerOnly, style: OpenBasketText.meta(ob.meta)),
          ],
          if (me != null) ...[
            const SizedBox(height: 22),
            SectionLabel(l10n.settingsNotifications),
            const SizedBox(height: 4),
            ListRow(
              title: l10n.settingsNotifyOpened,
              trailing: ObSwitch(
                value: me.notifyBasketOpened,
                onChanged: (v) =>
                    _setNotifications(context, ref, me, basketOpened: v),
              ),
            ),
            ListRow(
              title: l10n.settingsNotifyClosingSoon,
              trailing: ObSwitch(
                value: me.notifyClosingSoon,
                onChanged: (v) =>
                    _setNotifications(context, ref, me, closingSoon: v),
              ),
            ),
            ListRow(
              title: l10n.settingsNotifySettled,
              trailing: ObSwitch(
                value: me.notifySettlementReady,
                onChanged: (v) =>
                    _setNotifications(context, ref, me, settlementReady: v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.settingsNotificationsNote,
                style: OpenBasketText.meta(ob.meta).copyWith(fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 14),
          ListRow(
            title: l10n.settingsSignOut,
            onTap: ref.watch(signOutProvider),
          ),
          ListRow(
            title: l10n.settingsLeave(household.name),
            subtitle: l10n.settingsLeaveNote,
            destructive: true,
            onTap: () => _leave(context, ref, household),
          ),
          Divider(height: 1, color: ob.rule),
          const SizedBox(height: 16),
          Text(
            switch ((version, email)) {
              (final v?, final e?) => l10n.settingsFooterEmail(v, e),
              (final v?, null) => l10n.settingsFooter(v),
              _ => '',
            },
            style: OpenBasketText.mono(
              color: ob.meta,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setNotifications(
    BuildContext context,
    WidgetRef ref,
    HouseholdMember me, {
    bool? basketOpened,
    bool? closingSoon,
    bool? settlementReady,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(householdControllerProvider)
          .setNotifications(
            basketOpened: basketOpened ?? me.notifyBasketOpened,
            closingSoon: closingSoon ?? me.notifyClosingSoon,
            settlementReady: settlementReady ?? me.notifySettlementReady,
          );
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    }
  }
}
