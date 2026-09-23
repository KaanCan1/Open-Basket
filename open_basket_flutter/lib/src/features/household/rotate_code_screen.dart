import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/failure_message.dart';
import '../../core/theme.dart';
import 'household_controller.dart';
import 'members_screen.dart';

/// Screen 18. Changing the code is the one way to shut a door that was left
/// open — a code in an old group chat — so it says exactly what it does and
/// does not do before doing it (ADR-006: the old code stops working at once).
///
/// The server picks the new code, so it is shown after rotating rather than
/// before, and the share sheet opens with it straight away: rotating is
/// almost always followed by sending the new one to someone.
class RotateCodeScreen extends ConsumerStatefulWidget {
  const RotateCodeScreen({super.key});

  @override
  ConsumerState<RotateCodeScreen> createState() => _RotateCodeScreenState();
}

class _RotateCodeScreenState extends ConsumerState<RotateCodeScreen> {
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
      if (mounted) context.pop();
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    } finally {
      if (mounted) setState(() => _rotating = false);
    }
  }

  /// "Kaan, Ayşe, Deniz and Mert".
  static String _names(AppLocalizations l10n, List<String> names) {
    if (names.length == 1) return names.single;
    return l10n.namesAnd(
      names.sublist(0, names.length - 1).join(', '),
      names.last,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final household = ref.watch(myHouseholdProvider).value;
    final members = ref.watch(activeMembersProvider).value ?? const [];
    if (household == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final old = _oldCode ?? household.code;
    final muted = theme.textTheme.bodySmall!.color!;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Text(l10n.rotateTitle, style: theme.textTheme.displayLarge),
          const SizedBox(height: 8),
          Text(l10n.rotateBlurb, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 28),
          _CodeLine(
            label: l10n.rotateOld,
            note: l10n.rotateOldNote,
            child: Text(
              old,
              style: OpenBasketText.money(muted).copyWith(
                decoration: _newCode == null
                    ? null
                    : TextDecoration.lineThrough,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _CodeLine(
            label: l10n.rotateNew,
            note: _newCode == null ? l10n.rotateNewNote : l10n.rotateNewDone,
            child: _newCode == null
                ? Text('– – – – – –', style: OpenBasketText.money(muted))
                : CodeBoxes(code: _newCode!),
          ),
          const SizedBox(height: 24),
          Text(l10n.rotateWarning, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            members.length <= 1
                ? l10n.rotateKeepPlaceOne
                : l10n.rotateKeepPlace(
                    _names(l10n, [for (final m in members) m.displayName]),
                  ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(l10n.rotateOwnerOnly, style: theme.textTheme.bodySmall),
          const SizedBox(height: 32),
          Builder(
            builder: (final buttonContext) => FilledButton(
              onPressed: _rotating || _newCode != null
                  ? null
                  : () => _rotate(buttonContext),
              child: _rotating
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.rotateAction),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _rotating ? null : () => context.pop(),
            child: Text(l10n.rotateKeep(old)),
          ),
        ],
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({
    required this.label,
    required this.note,
    required this.child,
  });

  final String label;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              const Spacer(),
              Text(note, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
