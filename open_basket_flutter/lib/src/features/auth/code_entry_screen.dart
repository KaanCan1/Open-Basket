import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/theme.dart';
import 'sign_in_controller.dart';

/// Screens 02 and 03. Six digits, and the three ways they can fail.
class CodeEntryScreen extends ConsumerStatefulWidget {
  const CodeEntryScreen({required this.email, super.key});

  final String email;

  @override
  ConsumerState<CodeEntryScreen> createState() => _CodeEntryScreenState();
}

class _CodeEntryScreenState extends ConsumerState<CodeEntryScreen> {
  /// Mirrors the server's own cooldown (ADR-004). The server enforces it
  /// regardless; this only stops the button lying about what will happen.
  static const _resendCooldown = Duration(seconds: 24);

  final _code = TextEditingController();
  Timer? _ticker;
  int _secondsLeft = _resendCooldown.inSeconds;
  bool _verifying = false;
  SignInFailure? _failure;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _ticker?.cancel();
    setState(() => _secondsLeft = _resendCooldown.inSeconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (final timer) {
      if (!mounted) return timer.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _verify() async {
    setState(() {
      _verifying = true;
      _failure = null;
    });
    try {
      await ref
          .read(signInControllerProvider)
          .verifyCode(widget.email, _code.text);
      // The session manager now holds a token, so the router moves us on.
    } catch (error) {
      if (!mounted) return;
      setState(() => _failure = failureFrom(error));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    await ref.read(signInControllerProvider).requestCode(widget.email);
    if (!mounted) return;
    setState(() {
      _code.clear();
      _failure = null;
    });
    _startCooldown();
  }

  ({String title, String note})? _failureCopy(AppLocalizations l10n) =>
      switch (_failure) {
        SignInFailure.wrongCode => (
          title: l10n.codeEntryMismatch,
          note: l10n.codeEntryMismatchNote,
        ),
        SignInFailure.expiredCode => (
          title: l10n.codeEntryExpired,
          note: l10n.codeEntryExpiredNote,
        ),
        SignInFailure.tooManyAttempts => (
          title: l10n.codeEntryBurned,
          note: l10n.codeEntryBurnedNote,
        ),
        SignInFailure.badEmail || SignInFailure.offline => (
          title: l10n.commonSomethingWentWrong,
          note: l10n.commonOfflineNote,
        ),
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall!.color!;
    final failure = _failureCopy(l10n);
    final canResend = _secondsLeft <= 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.codeEntryTitle, style: theme.textTheme.displayLarge),
              const SizedBox(height: 10),
              Text(
                l10n.codeEntrySentTo(widget.email),
                style: OpenBasketText.body(muted),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _code,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: OpenBasketText.countdown(
                  theme.colorScheme.onSurface,
                ).copyWith(fontSize: 34, letterSpacing: 10),
                decoration: const InputDecoration(counterText: ''),
                onChanged: (final value) {
                  if (value.length == 6 && !_verifying) _verify();
                },
              ),
              if (failure != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        failure.title,
                        style: OpenBasketText.item(theme.colorScheme.surface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        failure.note,
                        style: OpenBasketText.meta(OpenBasketColors.metaDark),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _verifying || _code.text.length != 6
                    ? null
                    : _verify,
                child: _verifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.codeEntryContinue),
              ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: kMinTapTarget),
                  child: TextButton(
                    onPressed: canResend ? _resend : null,
                    child: Text(
                      canResend
                          ? l10n.codeEntryResend
                          : '${l10n.codeEntryResendIn} '
                                '0:${_secondsLeft.toString().padLeft(2, '0')}',
                      style: OpenBasketText.meta(
                        canResend ? theme.colorScheme.onSurface : muted,
                      ),
                    ),
                  ),
                ),
              ),
              if (canResend)
                Text(
                  l10n.codeEntryResendNote,
                  textAlign: TextAlign.center,
                  style: OpenBasketText.meta(muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
