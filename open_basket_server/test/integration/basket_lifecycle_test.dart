import 'package:clock/clock.dart';
import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:open_basket_server/src/services/analytics_service.dart';
import 'package:open_basket_server/src/services/basket_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

Matcher _fails(BasketError error) =>
    throwsA(predicate((final e) => _errorOf(e) == error));

/// Far enough ahead that nothing this test schedules can fire while it runs.
/// The test server's future call manager is real; a basket closing in the
/// background halfway through an assertion is the kind of flake that costs a
/// day to find.
final _noon = DateTime.utc(2030, 5, 1, 12);

void main() {
  withServerpod('Given the basket endpoint', (sessionBuilder, endpoints) {
    setUpAll(AuthSetup.configureForTests);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    const kaan = '11111111-1111-4111-8111-111111111111';
    const ayse = '22222222-2222-4222-8222-222222222222';
    const mert = '33333333-3333-4333-8333-333333333333';

    /// A household with Kaan as owner and Ayşe as a member.
    Future<TestSessionBuilder> aHousehold() async {
      final owner = asUser(kaan);
      final household = await endpoints.household.create(owner, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      return owner;
    }

    test(
      'rule 4 is enforced by a partial unique index, not just by our check',
      () async {
        // This asserts the hand-written index in the migration is still
        // there. `serverpod create-migration` regenerates definition.sql from
        // the models, which cannot express a partial index — so a future
        // migration will silently drop this unless someone re-adds it. When
        // this test fails, that is what happened.
        final session = sessionBuilder.build();
        final rows = await session.db.unsafeQuery(
          "SELECT indexdef FROM pg_indexes "
          "WHERE tablename = 'basket' AND indexname = @name",
          parameters: QueryParameters.named({
            'name': BasketService.openBasketIndexName,
          }),
        );

        expect(
          rows,
          hasLength(1),
          reason:
              'The ${BasketService.openBasketIndexName} index is missing. '
              'Re-add it by hand to the latest migration, in BOTH '
              'definition.sql (a fresh database is built from that one) and '
              'migration.sql (an existing one is upgraded with that one).',
        );
        final definition = rows.single.toColumnMap()['indexdef'] as String;
        expect(definition, contains('UNIQUE'));
        expect(definition, contains('householdId'));
        expect(
          definition,
          contains("WHERE (status = 'open'"),
          reason: 'A non-partial unique index would allow one basket ever.',
        );
      },
    );

    test('opening a basket puts the caller in charge of it', () async {
      final owner = await aHousehold();

      final basket = await withClock(
        Clock.fixed(_noon),
        () => endpoints.basket.open(owner, durationMinutes: 10),
      );

      expect(basket.status, BasketStatus.open);
      expect(basket.openedAt, _noon);
      // Rule 1: the server computed this, not the client.
      expect(basket.closesAt, _noon.add(const Duration(minutes: 10)));
      expect(basket.extendCount, 0);
      expect(basket.closedAutomatically, isFalse);
      expect(basket.frozenAt, isNull);

      final members = await endpoints.household.listMembers(owner);
      final kaanMember = members.firstWhere(
        (final m) => m.role == MemberRole.owner,
      );
      expect(basket.shopperMemberId, kaanMember.id);
    });

    test('the basket keeps the currency it opened with (ADR-008)', () async {
      final owner = await aHousehold();
      await endpoints.household.setCurrency(owner, 'EUR');

      final basket = await endpoints.basket.open(owner, durationMinutes: 5);
      expect(basket.currencyCode, 'EUR');

      // Changing the household setting afterwards must not rewrite a run that
      // is already under way.
      await endpoints.household.setCurrency(owner, 'TRY');
      final reloaded = await endpoints.basket.getActive(owner);
      expect(reloaded!.currencyCode, 'EUR');
    });

    test('rule 4: a household gets one open basket at a time', () async {
      final owner = await aHousehold();
      await endpoints.basket.open(owner, durationMinutes: 10);

      await expectLater(
        endpoints.basket.open(owner, durationMinutes: 10),
        _fails(BasketError.householdAlreadyHasOpenBasket),
      );

      // Not even by somebody else in the same household.
      await expectLater(
        endpoints.basket.open(asUser(ayse), durationMinutes: 10),
        _fails(BasketError.householdAlreadyHasOpenBasket),
      );
    });

    test('the index refuses a second open basket at the database', () async {
      final owner = await aHousehold();
      final session = sessionBuilder.build();
      final first = await endpoints.basket.open(owner, durationMinutes: 10);

      // Straight at the database, bypassing the check in `open`. This is the
      // state two racing calls produce, and it proves both that the index
      // bites and that the name `open` matches on is the name Postgres
      // actually reports — if those two drift apart, a real race surfaces to
      // the shopper as a 500 instead of "someone already has one open".
      Object? thrown;
      try {
        await Basket.db.insertRow(
          session,
          first.copyWith(id: null, closesAt: first.closesAt),
        );
      } catch (e) {
        thrown = e;
      }

      expect(thrown, isA<DatabaseUniqueViolationException>());
      expect(
        (thrown as DatabaseUniqueViolationException).constraintName,
        BasketService.openBasketIndexName,
      );
    });

    test('a shopping run cannot be booked for a silly length', () async {
      final owner = await aHousehold();

      await expectLater(
        endpoints.basket.open(owner, durationMinutes: 0),
        _fails(BasketError.invalidDuration),
      );
      await expectLater(
        endpoints.basket.open(owner, durationMinutes: -5),
        _fails(BasketError.invalidDuration),
      );
      await expectLater(
        endpoints.basket.open(owner, durationMinutes: 121),
        _fails(BasketError.invalidDuration),
      );

      expect(await endpoints.basket.getActive(owner), isNull);
    });

    test('you cannot shop at another household\'s store', () async {
      final owner = await aHousehold();

      final outsider = asUser(mert);
      final other = await endpoints.household.create(outsider, 'Other house');
      final theirStore = await Store.db.insertRow(
        sessionBuilder.build(),
        Store(householdId: other.id!, name: 'Their Migros'),
      );

      await expectLater(
        endpoints.basket.open(
          owner,
          storeId: theirStore.id,
          durationMinutes: 10,
        ),
        _fails(BasketError.storeNotFound),
      );
    });

    test('only the shopper can extend, freeze or cancel', () async {
      final owner = await aHousehold();
      final basket = await endpoints.basket.open(owner, durationMinutes: 10);
      final other = asUser(ayse);

      await expectLater(
        endpoints.basket.extend(other, basket.id!),
        _fails(BasketError.notTheShopper),
      );
      await expectLater(
        endpoints.basket.freeze(other, basket.id!),
        _fails(BasketError.notTheShopper),
      );
      await expectLater(
        endpoints.basket.cancel(other, basket.id!),
        _fails(BasketError.notTheShopper),
      );
    });

    test('a basket in another household might as well not exist', () async {
      final owner = await aHousehold();
      final basket = await endpoints.basket.open(owner, durationMinutes: 10);

      final outsider = asUser(mert);
      await endpoints.household.create(outsider, 'Other house');

      // Not notTheShopper: that would confirm the id is a real basket.
      await expectLater(
        endpoints.basket.freeze(outsider, basket.id!),
        _fails(BasketError.basketNotFound),
      );
      expect(await endpoints.basket.getActive(outsider), isNull);
    });

    test('extend adds five minutes to the deadline, once (ADR-009)', () async {
      final owner = await aHousehold();

      final basket = await withClock(
        Clock.fixed(_noon),
        () => endpoints.basket.open(owner, durationMinutes: 10),
      );

      // Two minutes later. Extending must buy five more minutes on top of
      // what is left, not reset the clock to now + 5.
      final extended = await withClock(
        Clock.fixed(_noon.add(const Duration(minutes: 8))),
        () => endpoints.basket.extend(owner, basket.id!),
      );

      expect(
        extended.closesAt,
        basket.closesAt.add(const Duration(minutes: 5)),
      );
      expect(extended.extendCount, 1);

      await expectLater(
        endpoints.basket.extend(owner, basket.id!),
        _fails(BasketError.extensionAlreadyUsed),
      );
    });

    test('freezing is "at checkout": no items, still yours', () async {
      final owner = await aHousehold();
      final basket = await withClock(
        Clock.fixed(_noon),
        () => endpoints.basket.open(owner, durationMinutes: 10),
      );

      final frozen = await withClock(
        Clock.fixed(_noon.add(const Duration(minutes: 4))),
        () => endpoints.basket.freeze(owner, basket.id!),
      );

      expect(frozen.status, BasketStatus.frozen);
      expect(frozen.frozenAt, _noon.add(const Duration(minutes: 4)));
      // The shopper beat the clock, so this was not the timer's doing.
      expect(frozen.closedAutomatically, isFalse);
      // Kept as a record of when the run was booked to end.
      expect(frozen.closesAt, basket.closesAt);

      // A frozen basket is still the active one — it is waiting for prices,
      // and a client coming back from the background has to find it.
      expect((await endpoints.basket.getActive(owner))!.id, basket.id);

      // And it cannot be frozen, extended or cancelled twice.
      await expectLater(
        endpoints.basket.freeze(owner, basket.id!),
        _fails(BasketError.basketNotOpen),
      );
      await expectLater(
        endpoints.basket.extend(owner, basket.id!),
        _fails(BasketError.basketNotOpen),
      );
    });

    test('cancelling ends the run and frees the household', () async {
      final owner = await aHousehold();
      final basket = await endpoints.basket.open(owner, durationMinutes: 10);

      final cancelled = await endpoints.basket.cancel(owner, basket.id!);
      expect(cancelled.status, BasketStatus.cancelled);

      expect(await endpoints.basket.getActive(owner), isNull);
      // Rule 4 released: the next run can start straight away.
      final next = await endpoints.basket.open(owner, durationMinutes: 10);
      expect(next.id, isNot(basket.id));
    });

    test('a frozen basket does not stop the next run', () async {
      // Found on the deployed server: the first basket closed itself, and the
      // household could never open another. Rule 4 is one *open* basket; a
      // frozen one is waiting for prices, and with settlement not built yet
      // and cancel only allowed while open, counting it locked the household
      // out for good.
      final owner = await aHousehold();
      final first = await endpoints.basket.open(owner, durationMinutes: 10);
      await endpoints.basket.freeze(owner, first.id!);

      final second = await endpoints.basket.open(owner, durationMinutes: 10);

      expect(second.id, isNot(first.id));
      expect(second.status, BasketStatus.open);
    });

    test('the active basket is the open one when there is one', () async {
      final owner = await aHousehold();
      final first = await endpoints.basket.open(owner, durationMinutes: 10);
      await endpoints.basket.freeze(owner, first.id!);
      final second = await endpoints.basket.open(owner, durationMinutes: 10);

      expect((await endpoints.basket.getActive(owner))!.id, second.id);
    });

    test(
      'with nothing open, the active basket is the latest frozen one',
      () async {
        final owner = await aHousehold();
        final first = await withClock(
          Clock.fixed(_noon),
          () => endpoints.basket.open(owner, durationMinutes: 10),
        );
        await endpoints.basket.freeze(owner, first.id!);
        final second = await withClock(
          Clock.fixed(_noon.add(const Duration(hours: 1))),
          () => endpoints.basket.open(owner, durationMinutes: 10),
        );
        await endpoints.basket.freeze(owner, second.id!);

        // Without ordering, which of the two came back was the database's
        // choice.
        expect((await endpoints.basket.getActive(owner))!.id, second.id);
      },
    );

    test('someone with no household cannot open anything', () async {
      await expectLater(
        endpoints.basket.open(asUser(mert), durationMinutes: 10),
        _fails(BasketError.notAMember),
      );
      await expectLater(
        endpoints.basket.getActive(asUser(mert)),
        _fails(BasketError.notAMember),
      );
    });

    test('getServerTime answers in UTC (rule 1)', () async {
      final now = await withClock(
        Clock.fixed(_noon),
        () => endpoints.basket.getServerTime(asUser(kaan)),
      );
      expect(now, _noon);
      expect(now.isUtc, isTrue);
    });

    test('every lifecycle step is written to analytics (rule 8)', () async {
      final owner = await aHousehold();
      final session = sessionBuilder.build();

      final basket = await endpoints.basket.open(owner, durationMinutes: 10);
      await endpoints.basket.extend(owner, basket.id!);
      await endpoints.basket.freeze(owner, basket.id!);

      final events = await AnalyticsEvent.db.find(
        session,
        where: (final t) => t.basketId.equals(basket.id),
      );

      expect(
        events.map((final e) => e.type),
        containsAll([
          AnalyticsType.basketOpened,
          AnalyticsType.basketExtended,
          AnalyticsType.basketFrozen,
        ]),
      );
    });
  });

  // Rollbacks wrap every test in one transaction, and the harness refuses
  // concurrent calls inside it — which is exactly what this test needs. So it
  // gets its own server group with rollbacks off. The ephemeral database is
  // dropped when the group ends, so nothing leaks into the rest of the suite.
  withServerpod(
    'Given two people opening a basket at the same moment',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      setUpAll(AuthSetup.configureForTests);

      TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
      );

      const kaan = '44444444-4444-4444-8444-444444444444';
      const ayse = '55555555-5555-4555-8555-555555555555';

      test('exactly one of them gets the basket', () async {
        final owner = asUser(kaan);
        final household = await endpoints.household.create(owner, 'Race house');
        await endpoints.household.joinWithCode(asUser(ayse), household.code);

        // Both calls can read "no open basket" before either inserts. That is
        // the case the transaction check cannot catch and the partial unique
        // index can. (PLAN has the race on Day 13-14; it is here because Day 8
        // is where the index was written, and an unproven index is not a
        // guarantee.)
        final results = await Future.wait([
          endpoints.basket
              .open(owner, durationMinutes: 10)
              .then<Object?>((final b) => b)
              .catchError((Object e) => e),
          endpoints.basket
              .open(asUser(ayse), durationMinutes: 10)
              .then<Object?>((final b) => b)
              .catchError((Object e) => e),
        ]);

        final opened = results.whereType<Basket>().toList();
        expect(opened, hasLength(1), reason: 'Two baskets got through rule 4.');

        final refused = results.where((final r) => r is! Basket).toList();
        expect(refused, hasLength(1));
        expect(
          _errorOf(refused.single),
          BasketError.householdAlreadyHasOpenBasket,
          reason: 'The loser saw a raw database error, not our own.',
        );
      });
    },
  );
}
