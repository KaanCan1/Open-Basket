import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/client_provider.dart';
import '../../core/failure_message.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import '../../../l10n/app_localizations.dart';
import 'household_code_formatter.dart';
import 'household_controller.dart';
import 'join_household_screen.dart';

/// Screen 04. The fork a signed-in user with no household lands on: start
/// one in the ink card, or type the six characters underneath. A refused
/// code moves on to the join screen (27, 28), which knows how to explain it.
class CreateOrJoinScreen extends ConsumerStatefulWidget {
  const CreateOrJoinScreen({super.key});

  @override
  ConsumerState<CreateOrJoinScreen> createState() => _CreateOrJoinScreenState();
}

class _CreateOrJoinScreenState extends ConsumerState<CreateOrJoinScreen> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  bool _creating = false;
  bool _joining = false;
  String? _createError;
  String? _joinError;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _createError = l10n.createHouseholdEmpty);
      return;
    }
    setState(() {
      _creating = true;
      _createError = null;
    });
    try {
      // The home screen underneath rebuilds off the invalidated provider.
      await ref.read(householdControllerProvider).create(name);
    } catch (error) {
      if (!mounted) return;
      setState(() => _createError = failureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _joining = true;
      _joinError = null;
    });
    try {
      await ref.read(householdControllerProvider).joinWithCode(_code.text);
    } on OpenBasketException catch (error) {
      if (!mounted) return;
      if (error.error == BasketError.unknownHouseholdCode ||
          error.error == BasketError.householdCodeRotated) {
        // Screens 27 and 28 are their own page, with the code still in the
        // boxes so the person can see what was refused.
        context.push(
          Routes.joinHousehold,
          extra: RefusedJoin(code: _code.text, error: error),
        );
      } else {
        setState(() => _joinError = failureMessage(l10n, error));
      }
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _joinError = failureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final email = ref.watch(myEmailProvider).value;
    final ready = _code.text.length == HouseholdCodeFormatter.length;
    const paper = OpenBasketColors.paper;

    return ObScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitle(
              l10n.householdChoiceHeadline,
              subtitle: l10n.householdChoiceBlurb,
            ),
            const SizedBox(height: 22),
            InkCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.householdChoiceCreate,
                    style: OpenBasketText.title(paper, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.householdChoiceCreateNote,
                    style: OpenBasketText.body(
                      OpenBasketColors.metaDark,
                    ).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    style: OpenBasketText.body(paper).copyWith(fontSize: 16),
                    cursorColor: paper,
                    decoration: InputDecoration(
                      hintText: l10n.createHouseholdHint,
                      hintStyle: OpenBasketText.body(
                        OpenBasketColors.metaDark,
                      ).copyWith(fontSize: 16),
                      fillColor: paper.withValues(alpha: 0.10),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: paper.withValues(alpha: 0.18),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: paper, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _creating ? null : _create(),
                  ),
                  if (_createError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _createError!,
                      style: OpenBasketText.meta(OpenBasketColors.dangerDark),
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: OpenBasketText.title(
                        OpenBasketColors.ink,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: _creating ? null : _create,
                    child: _creating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : Text(l10n.createHouseholdAction),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: Divider(color: ob.rule, height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    l10n.householdChoiceOr.toUpperCase(),
                    style: OpenBasketText.label(const Color(0xFF8E8E88)),
                  ),
                ),
                Expanded(child: Divider(color: ob.rule, height: 1)),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              l10n.householdChoiceJoinTitle,
              style: OpenBasketText.title(ob.onGround, fontSize: 20),
            ),
            const SizedBox(height: 14),
            CharBoxesField(
              controller: _code,
              autofocus: false,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: const [HouseholdCodeFormatter()],
              onChanged: (_) => setState(() => _joinError = null),
              onSubmitted: (_) => ready && !_joining ? _join() : null,
            ),
            if (_joinError != null) ...[
              const SizedBox(height: 10),
              Text(
                _joinError!,
                style: OpenBasketText.meta(Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 14),
            if (ready)
              PrimaryButton(
                label: l10n.joinHouseholdAction,
                busy: _joining,
                onPressed: _join,
              )
            else
              OutlineButton(
                label: l10n.joinHouseholdAction,
                quiet: true,
                onPressed: null,
              ),
            const SizedBox(height: 36),
            // The way back out. Without it, a mistyped email signed in
            // straight into this screen with nowhere to go but a household
            // nobody meant to make.
            Text(
              email == null
                  ? l10n.householdChoiceNotYou
                  : l10n.householdChoiceSignedInAs(email),
              textAlign: TextAlign.center,
              style: OpenBasketText.meta(ob.meta),
            ),
            Center(
              child: LinkText(
                l10n.settingsSignOut,
                onTap: ref.watch(signOutProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
