import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/client_provider.dart';
import '../../core/formatters.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../household/household_controller.dart';
import '../stores/stores_controller.dart';
import 'currency_screen.dart';
import '../../core/failure_message.dart';

/// Screen 19. The household's settings, and the way out.
///
/// The design's notification switches are left out until pushes exist
/// (Days 11-12): a switch that turns off nothing is a promise the app does
/// not keep.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    Household household,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: household.name);
    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (final context) => CupertinoAlertDialog(
        title: Text(l10n.settingsRenameTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            maxLength: 60,
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
    if (name == null || name.trim().isEmpty || name.trim() == household.name) {
      return;
    }
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(householdControllerProvider).rename(name);
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
    final theme = Theme.of(context);
    final household = ref.watch(myHouseholdProvider).value;
    final me = ref.watch(myMembershipProvider).value;
    final members = ref.watch(activeMembersProvider).value ?? const [];
    final stores = ref.watch(storesProvider).value ?? const <Store>[];
    final isOwner = me?.role == MemberRole.owner;

    if (household == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currency = household.currencyCode;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Text(l10n.settingsTitle, style: theme.textTheme.displayLarge),
          const SizedBox(height: 24),
          Text(l10n.settingsHousehold, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          _Row(
            label: l10n.settingsName,
            value: household.name,
            onTap: isOwner ? () => _rename(context, ref, household) : null,
          ),
          _Row(
            label: l10n.settingsCurrency,
            value:
                '${MoneyFormat.symbol(currency)} $currency · '
                '${CurrencyScreen.nameOf(l10n, currency)}',
            note: l10n.settingsCurrencyNote,
            onTap: () => context.push(Routes.currency),
          ),
          _Row(
            label: l10n.settingsStores,
            value: stores.isEmpty
                ? l10n.homeStoresNone
                : stores.map((s) => s.name).join(', '),
            onTap: () => context.push(Routes.stores),
          ),
          _Row(
            label: l10n.settingsMembers,
            value: l10n.settingsMembersValue(members.length, household.code),
          ),
          if (!isOwner) ...[
            const SizedBox(height: 8),
            Text(l10n.settingsOwnerOnly, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: ref.watch(signOutProvider),
            child: Text(l10n.settingsSignOut),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _leave(context, ref, household),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Column(
              children: [
                Text(l10n.settingsLeave(household.name)),
                Text(
                  l10n.settingsLeaveNote,
                  style: OpenBasketText.meta(theme.textTheme.bodySmall!.color!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.note,
    this.onTap,
  });

  final String label;
  final String value;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinTapTarget),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(value, style: theme.textTheme.titleMedium),
                  if (note != null)
                    Text(note!, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (onTap != null)
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
