import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../../../l10n/app_localizations.dart';
import 'household_controller.dart';
import '../../core/failure_message.dart';

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
      setState(() => _error = failureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);

    return ObScaffold(
      back: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitle(
              l10n.createHouseholdTitle,
              subtitle: l10n.createHouseholdBlurb,
            ),
            const SizedBox(height: 28),
            SectionLabel(l10n.createHouseholdLabel),
            const SizedBox(height: 4),
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: OpenBasketText.body(ob.onGround).copyWith(fontSize: 16),
              decoration: InputDecoration(hintText: l10n.createHouseholdHint),
              onSubmitted: (_) => _busy ? null : _create(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: OpenBasketText.meta(Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.createHouseholdAction,
              busy: _busy,
              onPressed: _create,
            ),
          ],
        ),
      ),
    );
  }
}
