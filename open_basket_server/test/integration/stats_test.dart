import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/future_calls/close_basket_future_call.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:open_basket_server/src/services/stats_service.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const kaan = '11111111-1111-4111-8111-111111111111';
const ayse = '22222222-2222-4222-8222-222222222222';
const mert = '33333333-3333-4333-8333-333333333333';
const jin = '44444444-4444-4444-8444-444444444444';

// Far enough ahead that the test server's own future call manager never
// fires anything these runs schedule.
final _t1 = DateTime.utc(2030, 5, 1, 12);
final _t2 = DateTime.utc(2030, 5, 1, 13);
final _t3 = DateTime.utc(2030, 5, 1, 14);

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

Future<T> _at<T>(DateTime when, Future<T> Function() action) =>
    withClock(Clock.fixed(when), action);

void main() {
  withServerpod('Given four runs in two households', (
    sessionBuilder,
    endpoints,
  ) {
    setUpAll(AuthSetup.configureForTests);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    /// The Kaya house (Kaan shops; Ayşe and Mert) has three finished runs:
    ///  1. 10 min. Kaan adds bread at +10 s, Ayşe milk at +30 s; frozen by
    ///     hand, priced, settled.
    ///  2. 20 min, extended once, nobody adds; the timer closes it.
    ///  3. 15 min. Mert adds eggs at +60 s; Kaan cancels.
    /// The Lee house (Jin alone) has one run still open: 5 min, tea at +20 s.
    Future<void> fourRuns() async {
      final shopper = asUser(kaan);
      final kaya = await endpoints.household.create(shopper, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), kaya.code);
      await endpoints.household.joinWithCode(asUser(mert), kaya.code);
      await endpoints.household.create(asUser(jin), 'Lee');

      final one = await _at(
        _t1,
        () => endpoints.basket.open(shopper, durationMinutes: 10),
      );
      final bread = await _at(
        _t1.add(const Duration(seconds: 10)),
        () => endpoints.basket.addItem(shopper, one.id!, 'Bread'),
      );
      final milk = await _at(
        _t1.add(const Duration(seconds: 30)),
        () => endpoints.basket.addItem(asUser(ayse), one.id!, 'Milk'),
      );
      await _at(
        _t1.add(const Duration(minutes: 2)),
        () => endpoints.basket.freeze(shopper, one.id!),
      );
      for (final item in [bread, milk]) {
        await endpoints.basket.markItem(
          shopper,
          item.id!,
          ItemStatus.picked,
          priceMinor: 1000,
        );
      }
      await endpoints.settlement.settle(shopper, one.id!);

      final two = await _at(
        _t2,
        () => endpoints.basket.open(shopper, durationMinutes: 20),
      );
      final extended = await _at(
        _t2.add(const Duration(minutes: 1)),
        () => endpoints.basket.extend(shopper, two.id!),
      );
      await _at(
        extended.closesAt,
        () => CloseBasketFutureCall().close(sessionBuilder.build(), two.id!),
      );

      final three = await _at(
        _t3,
        () => endpoints.basket.open(shopper, durationMinutes: 15),
      );
      await _at(
        _t3.add(const Duration(seconds: 60)),
        () => endpoints.basket.addItem(asUser(mert), three.id!, 'Eggs'),
      );
      await _at(
        _t3.add(const Duration(minutes: 2)),
        () => endpoints.basket.cancel(shopper, three.id!),
      );

      final four = await _at(
        _t3,
        () => endpoints.basket.open(asUser(jin), durationMinutes: 5),
      );
      await _at(
        _t3.add(const Duration(seconds: 20)),
        () => endpoints.basket.addItem(asUser(jin), four.id!, 'Tea'),
      );
    }

    test('the operator\'s report counts every household', () async {
      await fourRuns();

      final all = await StatsService.headline(sessionBuilder.build());

      expect(all['baskets'], 4);
      expect(all['households'], 2);
      expect(all['items'], 4);
      expect(all['items_per_basket'], 1.0);
      // How the open phase ended: one each.
      expect(all['auto_closed'], 1);
      expect(all['frozen_by_hand'], 1);
      expect(all['cancelled'], 1);
      expect(all['still_open'], 1);
      // Where runs stand now: the timed-out one still awaits its prices.
      expect(all['settled'], 1);
      expect(all['awaiting_settlement'], 1);
      // 10, 20, 15 and 5, the extension not counted as a choice.
      expect(all['avg_chosen_minutes'], 12.5);
      expect(all['extension_rate'], 0.25);
      // Finished runs only: 2 of 3, 0 of 3, 1 of 3.
      expect(all['member_share'], 0.3333);
      // Runs 1 and 3 had someone other than Kaan add; run 2 did not. Jin's
      // one-person house is left out, and still open anyway.
      expect(all['others_joined_rate'], 0.6667);
      // First items at 10, 60 and 20 s; from someone else at 30 and 60 s.
      expect(all['median_first_item_s'], 20.0);
      expect(all['median_first_other_s'], 45.0);
    });

    test('a member sees their own household, and only that', () async {
      await fourRuns();

      final kaya = jsonDecode(await endpoints.stats.report(asUser(ayse)));
      expect(kaya['baskets'], 3);
      expect(kaya['households'], 1);
      expect(kaya['items'], 3);
      expect(kaya['still_open'], 0);
      expect(kaya['avg_chosen_minutes'], 15.0);
      expect(kaya['median_first_item_s'], 35.0);

      final lee = jsonDecode(await endpoints.stats.report(asUser(jin)));
      expect(lee['baskets'], 1);
      expect(lee['items'], 1);
      // No finished run and no one else in the house: no answer, not zero.
      expect(lee['others_joined_rate'], isNull);
      expect(lee['median_first_other_s'], isNull);
    });

    test('someone in no household learns nothing', () async {
      await fourRuns();

      await expectLater(
        endpoints.stats.report(
          asUser('55555555-5555-4555-8555-555555555555'),
        ),
        throwsA(predicate((e) => _errorOf(e) == BasketError.notAMember)),
      );
    });

    test('an empty database reports zeros, not an error', () async {
      final all = await StatsService.headline(sessionBuilder.build());

      expect(all['baskets'], 0);
      expect(all['items'], 0);
      expect(all['member_share'], isNull);
    });

    group('scripts/report.sql', () {
      final script = File('../scripts/report.sql').readAsStringSync();

      test('leads with the same query the endpoint runs', () {
        expect(
          script,
          contains(
            StatsService.headlineSql.replaceAll(
              '@household::bigint',
              'NULL::bigint',
            ),
          ),
        );
      });

      test('every query in it runs', () async {
        await fourRuns();
        final session = sessionBuilder.build();
        final statements = script
            .split(RegExp(r';\s*\n'))
            .map(
              (s) => s
                  .split('\n')
                  .where((line) => !line.trimLeft().startsWith('--'))
                  .join('\n')
                  .trim(),
            )
            .where((s) => s.isNotEmpty)
            .toList();

        expect(statements, hasLength(6));
        for (final sql in statements) {
          final rows = await session.db.unsafeQuery(sql);
          expect(rows, isNotEmpty, reason: sql.split('\n').first);
        }
      });
    });
  });
}
