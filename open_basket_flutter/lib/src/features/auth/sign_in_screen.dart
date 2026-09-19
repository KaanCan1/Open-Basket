import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import 'sign_in_controller.dart';

/// Screen 01. The user types an address; the code arrives by email.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(signInControllerProvider).requestCode(email);
      if (!mounted) return;
      context.push(Routes.codeEntry, extra: email);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = failureFrom(error) == SignInFailure.badEmail
            ? l10n.signInInvalidEmail
            : l10n.commonSomethingWentWrong;
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall!.color!;

    return Scaffold(
      body: SafeArea(
        // Scrollable rather than balanced with flexible gaps: a raised
        // keyboard takes a few hundred pixels away, and the code screen next
        // door overflowed for exactly this reason.
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 96),
              Text(l10n.signInHeadline, style: theme.textTheme.displayLarge),
              const SizedBox(height: 12),
              Text(l10n.signInBlurb, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 40),
              Text(l10n.signInEmailLabel, style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(hintText: l10n.signInEmailHint),
                onSubmitted: (_) => _sending ? null : _send(),
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
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.signInSendCode),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.signInCodeNote,
                textAlign: TextAlign.center,
                style: OpenBasketText.meta(muted),
              ),
              const SizedBox(height: 72),
              Text(
                l10n.signInTerms,
                textAlign: TextAlign.center,
                style: OpenBasketText.meta(muted),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
