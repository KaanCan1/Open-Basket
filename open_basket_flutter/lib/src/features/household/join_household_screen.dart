import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
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
/// A code screen 04 already tried and the server refused, handed over so
/// this screen opens on the explanation rather than an empty box.
class RefusedJoin {
  const RefusedJoin({required this.code, required this.error});

  final String code;
  final OpenBasketException error;
}

class JoinHouseholdScreen extends ConsumerStatefulWidget {
  const JoinHouseholdScreen({this.attempt, super.key});

  final RefusedJoin? attempt;

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
  void initState() {
    super.initState();
    final attempt = widget.attempt;
    if (attempt != null) {
      _code.text = attempt.code;
      _failure = attempt.error.error;
      _triesLeft = attempt.error.triesLeft;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final attempt = widget.attempt;
    if (attempt != null && _error == null && _failure != null) {
      _error = failureMessage(AppLocalizations.of(context), attempt.error);
    }
  }

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
    final ob = Ob.of(context);
    final ready = _code.text.length == HouseholdCodeFormatter.length;
    final rotated = _failure == BasketError.householdCodeRotated;
    final unknown = _failure == BasketError.unknownHouseholdCode;

    final String? noticeBody;
    if (unknown) {
      noticeBody = [
        l10n.joinUnknownNote,
        if (_triesLeft != null) l10n.joinTriesLeft(_triesLeft!),
      ].join(' ');
    } else {
      noticeBody = _triesLeft == null ? null : l10n.joinTriesLeft(_triesLeft!);
    }

    return ObScaffold(
      back: true,
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
                  ScreenTitle(
                    rotated
                        ? l10n.errorHouseholdCodeRotated
                        : l10n.joinHouseholdTitle,
                    subtitle: rotated
                        ? l10n.joinRotatedNote
                        : l10n.joinHouseholdBlurb,
                  ),
                  const SizedBox(height: 28),
                  CharBoxesField(
                    controller: _code,
                    focusNode: _focus,
                    autofocus: widget.attempt == null,
                    enabled: !rotated,
                    struck: rotated,
                    error: unknown || (_error != null && !rotated),
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: const [HouseholdCodeFormatter()],
                    onChanged: (_) => setState(() {
                      _error = null;
                      _failure = null;
                    }),
                    onSubmitted: (_) => _busy || !ready ? null : _join(),
                  ),
                  const SizedBox(height: 22),
                  if (rotated)
                    _Rotated(onDifferent: _startOver)
                  else ...[
                    if (_error != null) ...[
                      InkNotice(title: _error!, body: noticeBody),
                      const SizedBox(height: 18),
                    ],
                    if (unknown)
                      PrimaryButton(
                        label: l10n.joinTryAgain,
                        onPressed: _startOver,
                      )
                    else
                      PrimaryButton(
                        label: l10n.joinHouseholdAction,
                        busy: _busy,
                        onPressed: ready ? _join : null,
                      ),
                    const SizedBox(height: 10),
                    OutlineButton(
                      label: l10n.joinPaste,
                      icon: CupertinoIcons.doc_on_doc,
                      quiet: true,
                      onPressed: _paste,
                    ),
                  ],
                  const Spacer(),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: ob.rule),
                  if (rotated)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: IconNote(text: l10n.joinNeverIn),
                    )
                  else
                    SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.joinNoCode,
                              style: OpenBasketText.body(
                                ob.meta,
                              ).copyWith(fontSize: 14),
                            ),
                          ),
                          LinkText(
                            l10n.joinStartOwn,
                            fontSize: 14,
                            onTap: () =>
                                context.pushReplacement(Routes.createHousehold),
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

/// Screen 28: the code was real, and has been replaced since the message was
/// sent. Nothing the person typed was wrong, so the way forward is asking for
/// the new one, not typing again.
class _Rotated extends StatelessWidget {
  const _Rotated({required this.onDifferent});

  final VoidCallback onDifferent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: ob.onGround, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.arrow_clockwise,
                    size: 17,
                    color: ob.onGround,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      l10n.joinAskTitle,
                      style: OpenBasketText.title(ob.onGround, fontSize: 15.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.joinAskNote,
                style: OpenBasketText.meta(ob.meta).copyWith(height: 1.5),
              ),
              const SizedBox(height: 14),
              Builder(
                builder: (final buttonContext) => InkButton(
                  label: l10n.joinAskAction,
                  icon: CupertinoIcons.share,
                  height: 50,
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
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlineButton(
          label: l10n.joinEnterDifferent,
          quiet: true,
          onPressed: onDifferent,
        ),
      ],
    );
  }
}
