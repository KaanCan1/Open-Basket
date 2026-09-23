import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_basket_flutter/l10n/app_localizations.dart';
import 'package:open_basket_flutter/src/features/household/members_screen.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2030, 9, 23, 20); // a Monday evening

  String joined(DateTime at, {bool owner = false}) {
    final j = describeJoined(at, now);
    return owner
        ? l10n.membersOwnerJoined(j.when, j.month)
        : l10n.membersJoined(j.when, j.month);
  }

  test('this week and last week are said as such', () {
    expect(joined(DateTime(2030, 9, 23, 8)), 'Joined this week');
    expect(joined(DateTime(2030, 9, 17)), 'Joined this week');
    expect(joined(DateTime(2030, 9, 12)), 'Joined last week');
  });

  test('older than that, the month; the year once it is not this one', () {
    expect(joined(DateTime(2030, 6, 2)), 'Joined June');
    expect(joined(DateTime(2029, 3, 2)), 'Joined March 2029');
  });

  test('the owner line leads with the role (screen 17)', () {
    expect(joined(DateTime(2030, 3, 2), owner: true), 'Owner · joined March');
  });

  test('the share text carries the code and where to get the app', () {
    final text = l10n.membersShareText('Kaya household', 'KZ74QM');
    expect(text, contains('KZ74QM'));
    expect(text, contains('open-basket.serverpod.space'));
  });

  test('names are listed the way people say them', () {
    expect(
      l10n.rotateKeepPlace(l10n.namesAnd('Kaan, Ayşe, Deniz', 'Mert')),
      'Kaan, Ayşe, Deniz and Mert keep their place. Nothing in history '
      'changes.',
    );
  });
}
