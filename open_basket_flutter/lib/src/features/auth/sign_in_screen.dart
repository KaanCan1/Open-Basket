import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
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
    final ob = Ob.of(context);

    return ObScaffold(
      // Scrollable rather than balanced with flexible gaps: a raised keyboard
      // takes a few hundred pixels away, and the code screen next door
      // overflowed for exactly this reason.
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: constraints.maxHeight * 0.14),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BrandMark(height: 58),
                ),
                const SizedBox(height: 30),
                Text(
                  l10n.signInHeadline,
                  style: OpenBasketText.display(
                    ob.onGround,
                  ).copyWith(fontSize: 36, height: 1.02, letterSpacing: -1.26),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.signInBlurb,
                  style: OpenBasketText.body(ob.meta).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 38),
                SectionLabel(l10n.signInEmailLabel),
                const SizedBox(height: 4),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  style: OpenBasketText.body(
                    ob.onGround,
                  ).copyWith(fontSize: 16),
                  decoration: InputDecoration(hintText: l10n.signInEmailHint),
                  onSubmitted: (_) => _sending ? null : _send(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: OpenBasketText.meta(
                      Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                PrimaryButton(
                  label: l10n.signInSendCode,
                  busy: _sending,
                  onPressed: _send,
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.signInCodeNote,
                  textAlign: TextAlign.center,
                  style: OpenBasketText.meta(ob.meta),
                ),
                const SizedBox(height: 72),
                Text(
                  l10n.signInTerms,
                  textAlign: TextAlign.center,
                  style: OpenBasketText.meta(ob.meta).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
