import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/client_provider.dart';
import '../../core/router.dart';
import '../../../l10n/app_localizations.dart';
import 'household_controller.dart';

/// Screen 04. The fork a signed-in user with no household lands on.
class CreateOrJoinScreen extends ConsumerWidget {
  const CreateOrJoinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final email = ref.watch(myEmailProvider).value;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 96),
              Text(
                l10n.householdChoiceHeadline,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.householdChoiceBlurb,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () => context.push(Routes.createHousehold),
                child: Text(l10n.householdChoiceCreate),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push(Routes.joinHousehold),
                child: Text(l10n.householdChoiceJoin),
              ),
              const SizedBox(height: 48),
              // The way back out. Without it, a mistyped email signed in
              // straight into this screen with nowhere to go but a
              // household nobody meant to make.
              Center(
                child: Text(
                  email == null
                      ? l10n.householdChoiceNotYou
                      : l10n.householdChoiceSignedInAs(email),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: ref.watch(signOutProvider),
                  child: Text(l10n.settingsSignOut),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
