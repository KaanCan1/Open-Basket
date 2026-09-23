import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_basket_flutter/l10n/app_localizations.dart';
import 'package:open_basket_flutter/src/features/history/history_screen.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2030, 5, 8, 21, 30); // a Wednesday evening

  String when(DateTime t) => describeWhen(l10n, t, now);

  test('today and yesterday say so', () {
    expect(when(DateTime(2030, 5, 8, 18, 29)), 'Today, 18:29');
    expect(when(DateTime(2030, 5, 7, 9, 5)), 'Yesterday, 09:05');
  });

  test('this week gives the weekday', () {
    expect(when(DateTime(2030, 5, 5, 11, 4)), 'Sunday, 11:04');
  });

  test('older runs give the date', () {
    expect(when(DateTime(2030, 4, 20, 18, 40)), 'Apr 20, 18:40');
  });

  test('just after midnight is still yesterday for a late run', () {
    final lateNight = DateTime(2030, 5, 9, 0, 10);
    expect(
      describeWhen(l10n, DateTime(2030, 5, 8, 23, 50), lateNight),
      'Yesterday, 23:50',
    );
  });
}
