import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/failure_message.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import 'household_controller.dart';
import 'members_screen.dart';

/// Screen 18. Changing the code is the one way to shut a door that was left
/// open — a code in an old group chat — so it says exactly what it does and
/// does not do before doing it (ADR-006: the old code stops working at once).
///
/// The server picks the new code, so it is shown after rotating rather than
/// before, and the share sheet opens with it straight away: rotating is
/// almost always followed by sending the new one to someone.
class RotateCodeScreen extends StatelessWidget {
  const RotateCodeScreen({super.key});

  /// As screen 18 draws it: a sheet over the members screen.
  static Future<void> show(BuildContext context) => showGlassSheet<void>(
    context: context,
    builder: (_) => const RotateCodeBody(),
  );

  @override
  Widget build(BuildContext context) =>
      const ObScaffold(back: true, body: RotateCodeBody());
}

class RotateCodeBody extends ConsumerStatefulWidget {
  const RotateCodeBody({super.key});

  @override
  ConsumerState<RotateCodeBody> createState() => _RotateCodeBodyState();
}

class _RotateCodeBodyState extends ConsumerState<RotateCodeBody> {
  bool _rotating = false;
  String? _newCode;

  /// Held from the moment of rotating: the household provider refreshes to
  /// the new code, and "old" must keep showing the one that just died.
  String? _oldCode;

  Future<void> _rotate(BuildContext buttonContext) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _rotating = true;
      _oldCode = ref.read(myHouseholdProvider).value?.code;
    });
    try {
      final household = await ref
          .read(householdControllerProvider)
          .rotateCode();
      if (!mounted) return;
      setState(() => _newCode = household.code);
      if (buttonContext.mounted) {
        await shareHouseholdCode(buttonContext, household.name, household.code);
      }
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    } finally {
      if (mounted) setState(() => _rotating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final household = ref.watch(myHouseholdProvider).value;
    final members = ref.watch(activeMembersProvider).value ?? const [];
    if (household == null) return const SkeletonList();
    final old = _oldCode ?? household.code;

    Widget bullet(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 12),
            decoration: BoxDecoration(
              color: ob.onGround,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: OpenBasketText.body(ob.onGround).copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitle(
            l10n.rotateTitle,
            subtitle: l10n.rotateBlurb,
            fontSize: 27,
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _CodeLine(
                  label: l10n.rotateOld,
                  note: l10n.rotateOldNote,
                  code: old,
                  struck: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 26, right: 12),
                child: Icon(
                  CupertinoIcons.arrow_right,
                  size: 18,
                  color: ob.onGround,
                ),
              ),
              Expanded(
                child: _CodeLine(
                  label: l10n.rotateNew,
                  note: _newCode == null
                      ? l10n.rotateNewNote
                      : l10n.rotateNewDone,
                  code: _newCode ?? '– – – – – –',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TonalCard(
            child: Column(
              children: [
                bullet(l10n.rotateWarning),
                bullet(
                  members.length <= 1
                      ? l10n.rotateKeepPlaceOne
                      : l10n.rotateKeepPlace(
                          joinNames(l10n, [
                            for (final m in members) m.displayName,
                          ]),
                        ),
                ),
                bullet(l10n.rotateOwnerOnly),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Builder(
            builder: (final buttonContext) => InkButton(
              label: l10n.rotateAction,
              onPressed: _rotating || _newCode != null
                  ? null
                  : () => _rotate(buttonContext),
            ),
          ),
          const SizedBox(height: 10),
          OutlineButton(
            label: l10n.rotateKeep(old),
            quiet: true,
            onPressed: _rotating ? null : () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({
    required this.label,
    required this.note,
    required this.code,
    this.struck = false,
  });

  final String label;
  final String note;
  final String code;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: OpenBasketText.label(ob.meta)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            code,
            style:
                OpenBasketText.mono(
                  color: struck ? ob.meta : ob.onGround,
                  fontSize: 22,
                  letterSpacing: 1.5,
                ).copyWith(
                  decoration: struck ? TextDecoration.lineThrough : null,
                  decorationColor: ob.meta,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(note, style: OpenBasketText.meta(ob.meta).copyWith(fontSize: 12)),
      ],
    );
  }
}
