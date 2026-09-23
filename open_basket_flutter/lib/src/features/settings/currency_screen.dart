import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../household/household_controller.dart';
import '../../core/failure_message.dart';

/// Screen 20. One currency for the whole household (rule 5, ADR-008).
///
/// The design's "Common" list, not all 168: these are the currencies the
/// households using the app actually hold, and every one of them shows how a
/// price will look, including that yen has no cents.
class CurrencyScreen extends ConsumerStatefulWidget {
  const CurrencyScreen({super.key});

  static const common = ['TRY', 'EUR', 'GBP', 'USD', 'CHF', 'JPY'];

  static String nameOf(AppLocalizations l10n, String code) => switch (code) {
    'TRY' => l10n.currencyNameTRY,
    'EUR' => l10n.currencyNameEUR,
    'GBP' => l10n.currencyNameGBP,
    'USD' => l10n.currencyNameUSD,
    'CHF' => l10n.currencyNameCHF,
    'JPY' => l10n.currencyNameJPY,
    _ => code,
  };

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  String? _picked;
  bool _saving = false;

  Future<void> _save(String code) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(householdControllerProvider).setCurrency(code);
      if (!mounted) return;
      context.pop();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final household = ref.watch(myHouseholdProvider).value;
    final me = ref.watch(myMembershipProvider).value;
    final isOwner = me?.role == MemberRole.owner;
    final current = household?.currencyCode ?? 'TRY';
    final picked = _picked ?? current;
    final codes = [
      current,
      for (final code in CurrencyScreen.common)
        if (code != current) code,
    ];

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Text(l10n.currencyTitle, style: theme.textTheme.displayLarge),
          const SizedBox(height: 4),
          Text(l10n.currencyBlurb, style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),
          for (final code in codes)
            _CurrencyRow(
              code: code,
              name: CurrencyScreen.nameOf(l10n, code),
              inUse: code == current,
              selected: code == picked,
              onTap: isOwner ? () => setState(() => _picked = code) : null,
            ),
          const SizedBox(height: 16),
          Text(l10n.currencyNote, style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          if (isOwner)
            FilledButton(
              onPressed: _saving || picked == current
                  ? null
                  : () => _save(picked),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.currencySave),
            )
          else
            Text(
              l10n.settingsOwnerOnly,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.code,
    required this.name,
    required this.inUse,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String name;
  final bool inUse;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ink = theme.textTheme.bodyLarge!.color!;
    final digits = MoneyFormat.minorUnitDigits(code);
    // 1,234.50 in whatever minor units this currency has.
    var sampleMinor = 1234;
    for (var i = 0; i < digits; i++) {
      sampleMinor *= 10;
    }
    if (digits > 0) sampleMinor += 50 * (digits >= 2 ? 1 : 0);
    final sample = MoneyFormat.format(sampleMinor, code);

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            // Some symbols are the code itself ("CHF"): scaled down to fit
            // the column rather than wrapping onto a second line.
            SizedBox(
              width: 40,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  MoneyFormat.symbol(code),
                  maxLines: 1,
                  style: OpenBasketText.money(ink).copyWith(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleMedium),
                  Text(
                    digits == 0
                        ? l10n.currencyNoCents(code, sample)
                        : l10n.currencySample(code, sample),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (inUse)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  l10n.currencyInUse,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            SizedBox.square(
              dimension: kMinTapTarget,
              child: selected
                  ? Icon(CupertinoIcons.checkmark_alt, color: ink)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
