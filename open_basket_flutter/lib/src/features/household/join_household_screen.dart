import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/router.dart';
import '../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import 'household_code_formatter.dart';
import 'household_controller.dart';
import '../../core/failure_message.dart';

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
  final _focus = FocusNode();
  bool _busy = false;
  String? _error;

  /// What the last refusal was, when it gets its own panel: a wrong code
  /// (screen 27) or one the household has since replaced (screen 28).
  BasketError? _failure;
  int? _triesLeft;

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _failure = null;
      _triesLeft = null;
    });
    try {
      await ref.read(householdControllerProvider).joinWithCode(_code.text);
      if (!mounted) return;
      context.pop();
    } on OpenBasketException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = failureMessage(l10n, error);
        _failure = error.error;
        _triesLeft = error.triesLeft;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = failureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Clears the field and the refusal, and puts the cursor back.
  void _startOver() {
    setState(() {
      _code.clear();
      _error = null;
      _failure = null;
      _triesLeft = null;
    });
    _focus.requestFocus();
  }

  /// The code usually arrives in a message; pasting the whole message works,
  /// because the formatter keeps only what a code can contain.
  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) return;
    final code = HouseholdCodeFormatter.fromMessage(text);
    setState(() {
      _code.text = code;
      _code.selection = TextSelection.collapsed(offset: code.length);
    });
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
                focusNode: _focus,
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
              if (_failure == BasketError.householdCodeRotated)
                _Rotated(onDifferent: _startOver)
              else if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: OpenBasketText.item(theme.colorScheme.error),
                ),
                if (_failure == BasketError.unknownHouseholdCode) ...[
                  const SizedBox(height: 4),
                  Text(l10n.joinUnknownNote, style: theme.textTheme.bodySmall),
                ],
                if (_triesLeft != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.joinTriesLeft(_triesLeft!),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _paste,
                  icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 18),
                  label: Text(l10n.joinPaste),
                ),
              ),
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
              if (_failure == BasketError.unknownHouseholdCode) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _startOver,
                  child: Text(l10n.joinTryAgain),
                ),
              ],
              const SizedBox(height: 32),
              Center(
                child: Text(l10n.joinNoCode, style: theme.textTheme.bodySmall),
              ),
              Center(
                child: TextButton(
                  onPressed: () =>
                      context.pushReplacement(Routes.createHousehold),
                  child: Text(l10n.joinStartOwn),
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

/// Screen 28: the code was real, and has been replaced since the message was
/// sent. Nothing the person typed was wrong, so the way forward is asking for
/// the new one, not typing again.
class _Rotated extends StatelessWidget {
  const _Rotated({required this.onDifferent});

  final VoidCallback onDifferent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.errorHouseholdCodeRotated,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(l10n.joinRotatedNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            Text(l10n.joinAskTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.joinAskNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            Builder(
              builder: (final buttonContext) => FilledButton(
                onPressed: () {
                  final box = buttonContext.findRenderObject() as RenderBox?;
                  SharePlus.instance.share(
                    ShareParams(
                      text: l10n.joinAskShareText,
                      sharePositionOrigin: box == null
                          ? null
                          : box.localToGlobal(Offset.zero) & box.size,
                    ),
                  );
                },
                child: Text(l10n.joinAskAction),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onDifferent,
              child: Text(l10n.joinEnterDifferent),
            ),
            const SizedBox(height: 12),
            Text(l10n.joinNeverIn, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
