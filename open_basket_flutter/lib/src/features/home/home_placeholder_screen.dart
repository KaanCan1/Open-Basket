import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/client_provider.dart';
import '../../core/theme.dart';

/// Stands in for screen 05 until the household work lands (Days 5-6).
///
/// Deliberately thin: its only job is to prove a signed-in session survives a
/// restart and that sign-out sends the router back.
class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final signOut = ref.watch(signOutProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('You are signed in', style: theme.textTheme.displayLarge),
                const SizedBox(height: 8),
                Text(
                  'Create or join a household goes here.',
                  textAlign: TextAlign.center,
                  style: OpenBasketText.body(
                    theme.textTheme.bodySmall!.color!,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
