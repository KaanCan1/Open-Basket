import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
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

  /// Wrong guesses at the current code. The server allows three (ADR-004)
  /// and burns the code on the third; counting here only lets the card say
  /// how many are left.
  int _wrong = 0;

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
      setState(() {
        _failure = failureFrom(error);
        if (_failure == SignInFailure.wrongCode) _wrong++;
      });
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
      _wrong = 0;
    });
    _startCooldown();
  }

  ({String title, String note})? _failureCopy(AppLocalizations l10n) =>
      switch (_failure) {
        SignInFailure.wrongCode => (
          title: l10n.codeEntryMismatch,
          note: _wrong < 3
              ? l10n.codeEntryMismatchTries(3 - _wrong)
              : l10n.codeEntryMismatchNote,
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
    final ob = Ob.of(context);
    final failure = _failureCopy(l10n);
    final canResend = _secondsLeft <= 0;

    return ObScaffold(
      back: true,
      // Scrollable because the content grows: the failure card adds a block,
      // and a raised keyboard takes another few hundred pixels.
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),
                  Text(
                    l10n.codeEntryTitle,
                    style: OpenBasketText.display(ob.onGround),
                  ),
                  const SizedBox(height: 12),
                  _SentTo(email: widget.email),
                  const SizedBox(height: 34),
                  CharBoxesField(
                    controller: _code,
                    error: failure != null,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (final value) {
                      if (_failure != null) setState(() => _failure = null);
                      if (value.length == 6 && !_verifying) _verify();
                    },
                  ),
                  const SizedBox(height: 24),
                  if (failure != null) ...[
                    InkNotice(title: failure.title, body: failure.note),
                    const SizedBox(height: 20),
                    OutlineButton(
                      label: l10n.codeEntryResend,
                      onPressed: canResend ? _resend : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      canResend
                          ? l10n.codeEntryResendNote
                          : l10n.codeEntryResendIn(
                              '0:${_secondsLeft.toString().padLeft(2, '0')}',
                            ),
                      textAlign: TextAlign.center,
                      style: OpenBasketText.meta(ob.meta),
                    ),
                  ] else ...[
                    _ResendRow(
                      secondsLeft: _secondsLeft,
                      onResend: _resend,
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: l10n.codeEntryContinue,
                      busy: _verifying,
                      onPressed: _code.text.length == 6 ? _verify : null,
                    ),
                  ],
                  const Spacer(),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: ob.rule),
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.codeEntryWrongAddress,
                            style: OpenBasketText.body(
                              ob.meta,
                            ).copyWith(fontSize: 14),
                          ),
                        ),
                        LinkText(
                          l10n.codeEntryChangeEmail,
                          fontSize: 14,
                          onTap: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SentTo extends StatelessWidget {
  const _SentTo({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final whole = l10n.codeEntrySentTo(email);
    final at = whole.indexOf(email);
    final style = OpenBasketText.body(ob.meta).copyWith(fontSize: 16);
    if (at < 0) return Text(whole, style: style);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: whole.substring(0, at)),
          TextSpan(
            text: email,
            style: TextStyle(color: ob.onGround, fontWeight: FontWeight.w700),
          ),
          TextSpan(text: whole.substring(at + email.length)),
        ],
      ),
    );
  }
}

/// "⏱ Resend in 0:24", then a link once the cooldown is over.
class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.secondsLeft, required this.onResend});

  final int secondsLeft;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    if (secondsLeft <= 0) {
      return Align(
        alignment: Alignment.centerLeft,
        child: LinkText(l10n.codeEntryResend, fontSize: 14, onTap: onResend),
      );
    }
    final time = '0:${secondsLeft.toString().padLeft(2, '0')}';
    final whole = l10n.codeEntryResendIn(time);
    final at = whole.indexOf(time);
    return SizedBox(
      height: kMinTapTarget,
      child: Row(
        children: [
          Icon(CupertinoIcons.clock, size: 16, color: ob.meta),
          const SizedBox(width: 9),
          Text.rich(
            TextSpan(
              style: OpenBasketText.body(ob.meta).copyWith(fontSize: 14),
              children: [
                TextSpan(text: whole.substring(0, at < 0 ? whole.length : at)),
                if (at >= 0)
                  TextSpan(
                    text: time,
                    style: OpenBasketText.mono(
                      color: ob.onGround,
                      fontSize: 14,
                    ),
                  ),
                if (at >= 0) TextSpan(text: whole.substring(at + time.length)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
