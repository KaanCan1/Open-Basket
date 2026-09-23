import 'dart:async';

import 'package:clock/clock.dart';
import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:open_basket_server/src/services/analytics_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

Matcher _fails(BasketError error) =>
    throwsA(predicate((final e) => _errorOf(e) == error));

final _noon = DateTime.utc(2030, 5, 1, 12);

const kaan = '11111111-1111-4111-8111-111111111111';
const ayse = '22222222-2222-4222-8222-222222222222';
const mert = '33333333-3333-4333-8333-333333333333';

/// Everything a settlement test starts from: Kaan shopping, Ayşe and Mert in
/// the house, Ayşe's milk and Kaan's bread on a basket that is now frozen.
typedef _Run = ({
  TestSessionBuilder shopper,
  TestSessionBuilder ayse,
  Basket basket,
  BasketItem milk,
  BasketItem bread,
});

Future<_Run> _aFrozenRun(
  TestSessionBuilder Function(String) asUser,
  TestEndpoints endpoints,
) async {
  final shopper = asUser(kaan);
  final household = await endpoints.household.create(shopper, 'Kaya');
  await endpoints.household.joinWithCode(asUser(ayse), household.code);
  await endpoints.household.joinWithCode(asUser(mert), household.code);
  final basket = await withClock(
    Clock.fixed(_noon),
    () => endpoints.basket.open(shopper, durationMinutes: 10),
  );
  final milk = await endpoints.basket.addItem(asUser(ayse), basket.id!, 'Milk');
  final bread = await endpoints.basket.addItem(shopper, basket.id!, 'Bread');
  await endpoints.basket.freeze(shopper, basket.id!);
  return (
    shopper: shopper,
    ayse: asUser(ayse),
    basket: basket,
    milk: milk,
    bread: bread,
  );
}

/// Prices both items and records a receipt 3 over the items: 4250 + 1500 =
/// 5750 of items, 5753 at the till, so each of three members owes 1 of the
/// gap and Kaan keeps the odd one.
Future<void> _priceEverything(TestEndpoints endpoints, _Run run) async {
  await endpoints.basket.markItem(
    run.shopper,
    run.milk.id!,
    ItemStatus.picked,
    priceMinor: 4250,
  );
  await endpoints.basket.markItem(
    run.shopper,
    run.bread.id!,
    ItemStatus.picked,
    priceMinor: 1500,
  );
  await endpoints.basket.setReceiptTotal(run.shopper, run.basket.id!, 5753);
}

void main() {
  withServerpod('Given a frozen run', (sessionBuilder, endpoints) {
    setUpAll(AuthSetup.configureForTests);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    Future<HouseholdMember> memberFor(String uuid) async =>
        (await HouseholdMember.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.userId.equals(UuidValue.fromString(uuid)),
        ))!;

    test('settling writes the lines and locks the basket', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      await _priceEverything(endpoints, run);

      final lines = await endpoints.settlement.settle(
        run.shopper,
        run.basket.id!,
      );

      final ayseMember = await memberFor(ayse);
      final mertMember = await memberFor(mert);
      final kaanMember = await memberFor(kaan);
      expect(lines, hasLength(2));
      final ayses = lines.singleWhere((l) => l.fromMemberId == ayseMember.id);
      expect(ayses.toMemberId, kaanMember.id);
      expect(ayses.itemsMinor, 4250);
      expect(ayses.receiptGapMinor, 1);
      expect(ayses.amountMinor, 4251);
      // Mert asked for nothing and still owes his share of the gap (ADR-007).
      final merts = lines.singleWhere((l) => l.fromMemberId == mertMember.id);
      expect(merts.amountMinor, 1);
      for (final line in lines) {
        expect(line.id, isNotNull, reason: 'The lines were not stored.');
      }

      final basket = await Basket.db.findById(
        sessionBuilder.build(),
        run.basket.id!,
      );
      expect(basket!.status, BasketStatus.settled);
    });

    test('everyone in the house can read the result', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      await _priceEverything(endpoints, run);
      final settled = await endpoints.settlement.settle(
        run.shopper,
        run.basket.id!,
      );

      final read = await endpoints.settlement.get(run.ayse, run.basket.id!);
      expect(read.map((l) => l.id), settled.map((l) => l.id));

      // And preview on a settled basket answers the same stored lines, so the
      // two can never disagree.
      final preview = await endpoints.settlement.preview(
        run.ayse,
        run.basket.id!,
      );
      expect(preview.map((l) => l.id), settled.map((l) => l.id));
    });

    test('get on a basket that is not settled is empty', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      expect(await endpoints.settlement.get(run.ayse, run.basket.id!), isEmpty);
    });

    test('preview shows the split without writing anything', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      await _priceEverything(endpoints, run);

      final preview = await endpoints.settlement.preview(
        run.ayse,
        run.basket.id!,
      );

      expect(preview, hasLength(2));
      for (final line in preview) {
        expect(line.id, isNull);
      }
      final stored = await SettlementLine.db.count(
        sessionBuilder.build(),
        where: (t) => t.basketId.equals(run.basket.id!),
      );
      expect(stored, 0);
    });

    test('preview works on a half-priced basket', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      await endpoints.basket.markItem(
        run.shopper,
        run.milk.id!,
        ItemStatus.picked,
        priceMinor: 4250,
      );

      final preview = await endpoints.settlement.preview(
        run.shopper,
        run.basket.id!,
      );

      final ayseMember = await memberFor(ayse);
      expect(
        preview.singleWhere((l) => l.fromMemberId == ayseMember.id).amountMinor,
        4250,
      );
    });

    test(
      'settling waits until every item is priced or not available',
      () async {
        final run = await _aFrozenRun(asUser, endpoints);
        // Milk picked but not priced; bread still just requested.
        await endpoints.basket.markItem(
          run.shopper,
          run.milk.id!,
          ItemStatus.picked,
        );

        await expectLater(
          endpoints.settlement.settle(run.shopper, run.basket.id!),
          _fails(BasketError.basketNotFullyPriced),
        );

        await endpoints.basket.markItem(
          run.shopper,
          run.milk.id!,
          ItemStatus.picked,
          priceMinor: 4250,
        );
        await expectLater(
          endpoints.settlement.settle(run.shopper, run.basket.id!),
          _fails(BasketError.basketNotFullyPriced),
          reason: 'A requested item would have counted as free.',
        );

        await endpoints.basket.markItem(
          run.shopper,
          run.bread.id!,
          ItemStatus.unavailable,
        );
        final lines = await endpoints.settlement.settle(
          run.shopper,
          run.basket.id!,
        );
        expect(lines, hasLength(1));
      },
    );

    test('a run where nothing was found settles to no lines', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      for (final item in [run.milk, run.bread]) {
        await endpoints.basket.markItem(
          run.shopper,
          item.id!,
          ItemStatus.unavailable,
        );
      }

      final lines = await endpoints.settlement.settle(
        run.shopper,
        run.basket.id!,
      );

      expect(lines, isEmpty);
      final basket = await Basket.db.findById(
        sessionBuilder.build(),
        run.basket.id!,
      );
      expect(basket!.status, BasketStatus.settled);
    });

    test('a run nobody added to still settles, and closes', () async {
      final shopper = asUser(kaan);
      final household = await endpoints.household.create(shopper, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      final basket = await endpoints.basket.open(shopper, durationMinutes: 10);
      await endpoints.basket.freeze(shopper, basket.id!);

      expect(await endpoints.settlement.settle(shopper, basket.id!), isEmpty);
      final settled = await Basket.db.findById(
        sessionBuilder.build(),
        basket.id!,
      );
      expect(settled!.status, BasketStatus.settled);
    });

    test('with nothing added, a receipt is split evenly (rule 6)', () async {
      final shopper = asUser(kaan);
      final household = await endpoints.household.create(shopper, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      final basket = await endpoints.basket.open(shopper, durationMinutes: 10);
      await endpoints.basket.freeze(shopper, basket.id!);
      await endpoints.basket.setReceiptTotal(shopper, basket.id!, 1001);

      final lines = await endpoints.settlement.settle(shopper, basket.id!);

      expect(lines, hasLength(1));
      final ayseMember = await memberFor(ayse);
      expect(lines.single.fromMemberId, ayseMember.id);
      expect(lines.single.amountMinor, 500);
    });

    test('settling twice is refused: the result is immutable', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      await _priceEverything(endpoints, run);
      await endpoints.settlement.settle(run.shopper, run.basket.id!);

      await expectLater(
        endpoints.settlement.settle(run.shopper, run.basket.id!),
        _fails(BasketError.basketAlreadySettled),
      );
      final stored = await SettlementLine.db.count(
        sessionBuilder.build(),
        where: (t) => t.basketId.equals(run.basket.id!),
      );
      expect(stored, 2);
    });

    test('only the shopper settles', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      await _priceEverything(endpoints, run);

      await expectLater(
        endpoints.settlement.settle(run.ayse, run.basket.id!),
        _fails(BasketError.notTheShopper),
      );
    });

    test('an open basket cannot be settled or previewed', () async {
      final shopper = asUser(kaan);
      await endpoints.household.create(shopper, 'Kaya');
      final basket = await endpoints.basket.open(shopper, durationMinutes: 10);

      await expectLater(
        endpoints.settlement.settle(shopper, basket.id!),
        _fails(BasketError.basketNotFrozen),
      );
      await expectLater(
        endpoints.settlement.preview(shopper, basket.id!),
        _fails(BasketError.basketNotFrozen),
      );
    });

    test('an outsider learns nothing', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      final outsider = asUser('44444444-4444-4444-8444-444444444444');
      await endpoints.household.create(outsider, 'Other house');

      for (final call in [
        () => endpoints.settlement.preview(outsider, run.basket.id!),
        () => endpoints.settlement.get(outsider, run.basket.id!),
        () => endpoints.settlement.settle(outsider, run.basket.id!),
      ]) {
        await expectLater(call(), _fails(BasketError.basketNotFound));
      }
    });

    test('the house sees it settle, and the stream ends', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      await _priceEverything(endpoints, run);
      final received = <BasketEvent>[];
      var ended = false;
      final sub = endpoints.basketStream
          .watch(run.ayse, run.basket.id!)
          .listen(received.add, onDone: () => ended = true);
      addTearDown(sub.cancel);
      await _until(() => received.isNotEmpty);

      await endpoints.settlement.settle(run.shopper, run.basket.id!);

      await _until(() => received.length >= 2);
      expect(received[1].type, BasketEventType.basketSettled);
      expect(received[1].basket!.status, BasketStatus.settled);
      await _until(() => ended);
    });

    test('someone who has left is not split across', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      await endpoints.household.leave(asUser(mert));
      await _priceEverything(endpoints, run);

      final lines = await endpoints.settlement.settle(
        run.shopper,
        run.basket.id!,
      );

      // Two members left in: Ayşe owes her milk plus half of the 3-unit gap
      // (1), and Mert — gone — owes nothing.
      final mertMember = await HouseholdMember.db.findFirstRow(
        sessionBuilder.build(),
        where: (t) => t.userId.equals(UuidValue.fromString(mert)),
      );
      expect(lines.where((l) => l.fromMemberId == mertMember!.id), isEmpty);
      expect(lines.single.amountMinor, 4251);
    });

    test('settling is written to analytics (rule 8)', () async {
      final run = await _aFrozenRun(asUser, endpoints);
      await _priceEverything(endpoints, run);
      await endpoints.settlement.settle(run.shopper, run.basket.id!);

      final events = await AnalyticsEvent.db.find(
        sessionBuilder.build(),
        where: (t) =>
            t.basketId.equals(run.basket.id) &
            t.type.equals(AnalyticsType.basketSettled),
      );
      expect(events, hasLength(1));
    });
  });

  // The harness refuses concurrent calls inside its per-test rollback
  // transaction, so the race gets its own group with rollbacks off.
  withServerpod(
    'Given two taps on "Work out who owes what"',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      setUpAll(AuthSetup.configureForTests);

      TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
      );

      test('the lines are written once', () async {
        final run = await _aFrozenRun(asUser, endpoints);
        await _priceEverything(endpoints, run);

        final results = await Future.wait([
          for (var i = 0; i < 2; i++)
            endpoints.settlement
                .settle(run.shopper, run.basket.id!)
                .then<Object?>((l) => l)
                .catchError((Object e) => e),
        ]);

        expect(results.whereType<List<SettlementLine>>(), hasLength(1));
        expect(
          _errorOf(results.firstWhere((r) => r is! List<SettlementLine>)),
          BasketError.basketAlreadySettled,
        );
        final stored = await SettlementLine.db.count(
          sessionBuilder.build(),
          where: (t) => t.basketId.equals(run.basket.id!),
        );
        expect(stored, 2);
      });
    },
  );
}

/// Waits for [condition], or gives up.
Future<void> _until(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError('Timed out waiting for the stream');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}
