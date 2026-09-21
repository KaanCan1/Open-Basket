import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import 'household_code_formatter.dart';
import 'household_controller.dart';
import 'household_failure.dart';

/// Screen 05b.
///
/// The field is deliberately forgiving. The server normalises too — it
/// upper-cases, strips spaces and dashes, and maps the characters the code
/// alphabet leaves out (O to zero, I and L to one). Doing it here as well is
/// not duplication for its own sake: it means what the person sees in the box
/// is what the server will read, so a rejected code is never a surprise.
class JoinHouseholdScreen extends ConsumerStatefulWidget {
  const JoinHouseholdScreen({super.key});

  @override
  ConsumerState<JoinHouseholdScreen> createState() =>
      _JoinHouseholdScreenState();
}

class _JoinHouseholdScreenState extends ConsumerState<JoinHouseholdScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(householdControllerProvider).joinWithCode(_code.text);
      if (!mounted) return;
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
    final ready = _code.text.length == HouseholdCodeFormatter.length;

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
                l10n.joinHouseholdTitle,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 12),
              Text(l10n.joinHouseholdBlurb, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 32),
              Text(l10n.joinHouseholdLabel, style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _code,
                autofocus: true,
                autocorrect: false,
                maxLength: HouseholdCodeFormatter.length,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: const [HouseholdCodeFormatter()],
                style: OpenBasketText.countdown(
                  theme.textTheme.bodyLarge!.color!,
                ).copyWith(fontSize: 28, letterSpacing: 6),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: l10n.joinHouseholdHint,
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _busy || !ready ? null : _join(),
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
                onPressed: _busy || !ready ? null : _join,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.joinHouseholdAction),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
