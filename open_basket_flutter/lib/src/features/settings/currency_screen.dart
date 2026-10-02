import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
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
  String _query = '';

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
    final ob = Ob.of(context);
    final household = ref.watch(myHouseholdProvider).value;
    final me = ref.watch(myMembershipProvider).value;
    final isOwner = me?.role == MemberRole.owner;
    final current = household?.currencyCode ?? 'TRY';
    final picked = _picked ?? current;
    final q = _query.trim().toLowerCase();
    final others = [
      for (final code in CurrencyScreen.common)
        if (code != current &&
            (q.isEmpty ||
                code.toLowerCase().contains(q) ||
                CurrencyScreen.nameOf(l10n, code).toLowerCase().contains(q)))
          code,
    ];

    return ObScaffold(
      back: true,
      backLabel: l10n.currencyBack,
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconNote(text: l10n.currencyNote, boxed: true),
          const SizedBox(height: 10),
          if (isOwner)
            PrimaryButton(
              label: l10n.currencySave,
              busy: _saving,
              onPressed: picked == current ? null : () => _save(picked),
            )
          else
            Text(
              l10n.settingsOwnerOnly,
              textAlign: TextAlign.center,
              style: OpenBasketText.meta(ob.meta),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          ScreenTitle(l10n.currencyTitle, subtitle: l10n.currencyBlurb),
          const SizedBox(height: 18),
          _InUseCard(
            code: current,
            name: CurrencyScreen.nameOf(l10n, current),
            selected: picked == current,
            onTap: isOwner ? () => setState(() => _picked = current) : null,
          ),
          const SizedBox(height: 14),
          Glass(
            radius: 16,
            shadow: false,
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: OpenBasketText.body(ob.onGround),
              decoration: InputDecoration(
                hintText: l10n.currencySearch(CurrencyScreen.common.length),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  size: 18,
                  color: ob.meta,
                ),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionLabel(l10n.currencyCommon),
          const SizedBox(height: 4),
          for (final code in others)
            _CurrencyRow(
              code: code,
              name: CurrencyScreen.nameOf(l10n, code),
              selected: code == picked,
              onTap: isOwner ? () => setState(() => _picked = code) : null,
            ),
        ],
      ),
    );
  }
}

String _sample(String code) {
  final digits = MoneyFormat.minorUnitDigits(code);
  // 1,234.50 in whatever minor units this currency has.
  var sampleMinor = 1234;
  for (var i = 0; i < digits; i++) {
    sampleMinor *= 10;
  }
  if (digits > 0) sampleMinor += 50 * (digits >= 2 ? 1 : 0);
  return MoneyFormat.format(sampleMinor, code);
}

/// The currency in use, on ink with its symbol on Signal (screen 20).
class _InUseCard extends StatelessWidget {
  const _InUseCard({
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String name;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const paper = OpenBasketColors.paper;
    return GestureDetector(
      onTap: onTap,
      child: InkCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OpenBasketColors.signal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    MoneyFormat.symbol(code),
                    style: OpenBasketText.mono(
                      color: OpenBasketColors.ink,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: OpenBasketText.title(paper)),
                  Text(
                    MoneyFormat.minorUnitDigits(code) == 0
                        ? l10n.currencyNoCents(code, _sample(code))
                        : l10n.currencySample(code, _sample(code)),
                    style: OpenBasketText.mono(
                      color: OpenBasketColors.metaDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: paper.withValues(alpha: 0.5)),
              ),
              child: Text(
                l10n.currencyInUse.toUpperCase(),
                style: OpenBasketText.mono(
                  color: paper,
                  fontSize: 10.5,
                  letterSpacing: 1.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String name;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final sample = _sample(code);
    final digits = MoneyFormat.minorUnitDigits(code);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: ob.rule)),
        ),
        child: Row(
          children: [
            // Some symbols are the code itself ("CHF"): scaled down to fit
            // the square rather than wrapping onto a second line.
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ob.tonal,
                borderRadius: BorderRadius.circular(11),
              ),
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    MoneyFormat.symbol(code),
                    maxLines: 1,
                    style: OpenBasketText.mono(
                      color: ob.onGround,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: OpenBasketText.item(ob.onGround)),
                  Text(
                    digits == 0
                        ? l10n.currencyNoCents(code, sample)
                        : l10n.currencySample(code, sample),
                    style: OpenBasketText.mono(
                      color: ob.meta,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            TickBox(
              state: selected ? TickState.got : TickState.empty,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
