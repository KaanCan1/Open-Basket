import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import 'household_controller.dart';
import 'household_failure.dart';

/// Screen 05a.
class CreateHouseholdScreen extends ConsumerStatefulWidget {
  const CreateHouseholdScreen({super.key});

  @override
  ConsumerState<CreateHouseholdScreen> createState() =>
      _CreateHouseholdScreenState();
}

class _CreateHouseholdScreenState extends ConsumerState<CreateHouseholdScreen> {
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.createHouseholdEmpty);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(householdControllerProvider).create(name);
      if (!mounted) return;
      // Pop rather than push home: the home screen is already underneath and
      // rebuilds off the invalidated provider. Pushing would leave the choice
      // screen in the stack for the back gesture to return to.
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = householdFailureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.createHouseholdTitle,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.createHouseholdBlurb,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Text(
                l10n.createHouseholdLabel,
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: l10n.createHouseholdHint),
                onSubmitted: (_) => _busy ? null : _create(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: OpenBasketText.meta(theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _create,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.createHouseholdAction),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
