import 'package:clock/clock.dart';
import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:open_basket_server/src/services/notification_copy.dart';
import 'package:open_basket_server/src/services/notification_service.dart';
import 'package:open_basket_server/src/services/push_sender.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const kaan = '11111111-1111-4111-8111-111111111111';
const ayse = '22222222-2222-4222-8222-222222222222';
const mert = '33333333-3333-4333-8333-333333333333';

// Far enough ahead that the test server's own future call manager never
// fires anything these baskets schedule.
final _noon = DateTime.utc(2030, 5, 1, 12);

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

/// Everything that would have gone out, and a way to pretend a token died.
class RecordingSender implements PushSender {
  final sent = <({String token, PushMessage message})>[];
  final gone = <String>{};

  List<String> get tokens => [for (final s in sent) s.token];

  @override
  Future<PushOutcome> send(
    Session session,
    String token,
    PushMessage message,
  ) async {
    if (gone.contains(token)) return PushOutcome.tokenGone;
    sent.add((token: token, message: message));
    return PushOutcome.sent;
  }
}

void main() {
  withServerpod('Given a household with phones', (sessionBuilder, endpoints) {
    setUpAll(AuthSetup.configureForTests);

    late RecordingSender push;
    setUp(() => PushSenders.override = push = RecordingSender());
    tearDown(() => PushSenders.override = null);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    /// Kaan (shopping), Ayşe and Mert, each named and each with one phone.
    Future<Household> aHouse() async {
      final household = await endpoints.household.create(
        asUser(kaan),
        'Kaya household',
      );
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      await endpoints.household.joinWithCode(asUser(mert), household.code);
      for (final (uuid, name) in [
        (kaan, 'Kaan'),
        (ayse, 'Ayşe'),
        (mert, 'Mert'),
      ]) {
        await endpoints.household.setMyName(asUser(uuid), name);
        await endpoints.device.registerToken(asUser(uuid), 'phone-$name');
      }
      return household;
    }

    Future<Basket> openAtNoon({int minutes = 10}) => withClock(
      Clock.fixed(_noon),
      () => endpoints.basket.open(asUser(kaan), durationMinutes: minutes),
    );

    Future<bool> remindAt(DateTime at, int basketId) => withClock(
      Clock.fixed(at),
      () => NotificationService.closingSoon(sessionBuilder.build(), basketId),
    );

    group('when a basket opens', () {
      test('everyone but the shopper is told', () async {
        await aHouse();
        await openAtNoon();

        expect(push.tokens, unorderedEquals(['phone-Ayşe', 'phone-Mert']));
        expect(
          push.sent.first.message.body,
          'Kaan is going shopping. Add what you need in the next 10 min.',
        );
        expect(push.sent.first.message.title, 'Kaya household');
      });

      test('the store is named when there is one', () async {
        await aHouse();
        final store = await endpoints.store.add(asUser(kaan), 'Migros');
        await withClock(
          Clock.fixed(_noon),
          () => endpoints.basket.open(
            asUser(kaan),
            durationMinutes: 12,
            storeId: store.id,
          ),
        );

        expect(
          push.sent.first.message.body,
          'Kaan is heading to Migros. Add what you need in the next 12 min.',
        );
      });

      test('a member who switched it off is not told (ADR-010)', () async {
        await aHouse();
        await endpoints.household.setNotificationPreferences(
          asUser(mert),
          basketOpened: false,
          closingSoon: true,
          settlementReady: true,
        );
        await openAtNoon();

        expect(push.tokens, ['phone-Ayşe']);
      });

      test('someone who left is not told', () async {
        await aHouse();
        await endpoints.household.leave(asUser(mert));
        await openAtNoon();

        expect(push.tokens, ['phone-Ayşe']);
      });

      test('a dead token is dropped and never tried again', () async {
        await aHouse();
        push.gone.add('phone-Mert');
        await openAtNoon();

        final left = await DeviceToken.db.find(sessionBuilder.build());
        expect(left.map((t) => t.token), isNot(contains('phone-Mert')));
      });

      test('with push not set up, the basket still opens', () async {
        await aHouse();
        PushSenders.override = null; // no credentials in the test config

        final basket = await openAtNoon();

        expect(basket.status, BasketStatus.open);
      });
    });

    group('two minutes before the close', () {
      test('only the people who have not added anything are nudged', () async {
        await aHouse();
        final basket = await openAtNoon();
        await withClock(
          Clock.fixed(_noon.add(const Duration(minutes: 1))),
          () => endpoints.basket.addItem(asUser(ayse), basket.id!, 'Milk'),
        );
        push.sent.clear();

        final sent = await remindAt(
          basket.closesAt.subtract(const Duration(minutes: 2)),
          basket.id!,
        );

        expect(sent, isTrue);
        expect(push.tokens, ['phone-Mert']);
        expect(push.sent.single.message.body, '2 minutes left on the basket.');
      });

      test('a reminder left over from before an extension does nothing '
          '(rule 2)', () async {
        await aHouse();
        final basket = await openAtNoon();
        await withClock(
          Clock.fixed(_noon.add(const Duration(minutes: 1))),
          () => endpoints.basket.extend(asUser(kaan), basket.id!),
        );
        push.sent.clear();

        // The original reminder time: the basket now has seven minutes left.
        final sent = await remindAt(
          basket.closesAt.subtract(const Duration(minutes: 2)),
          basket.id!,
        );

        expect(sent, isFalse);
        expect(push.sent, isEmpty);
      });

      test('a basket already at the till is left alone', () async {
        await aHouse();
        final basket = await openAtNoon();
        await withClock(
          Clock.fixed(_noon.add(const Duration(minutes: 3))),
          () => endpoints.basket.freeze(asUser(kaan), basket.id!),
        );
        push.sent.clear();

        expect(
          await remindAt(
            basket.closesAt.subtract(const Duration(minutes: 2)),
            basket.id!,
          ),
          isFalse,
        );
        expect(push.sent, isEmpty);
      });
    });

    group('when the run is settled', () {
      test('whoever owes is told how much, and to whom', () async {
        await aHouse();
        final basket = await openAtNoon();
        final milk = await withClock(
          Clock.fixed(_noon.add(const Duration(minutes: 1))),
          () => endpoints.basket.addItem(asUser(ayse), basket.id!, 'Milk'),
        );
        await withClock(
          Clock.fixed(_noon.add(const Duration(minutes: 2))),
          () => endpoints.basket.freeze(asUser(kaan), basket.id!),
        );
        await endpoints.basket.markItem(
          asUser(kaan),
          milk.id!,
          ItemStatus.picked,
          priceMinor: 8450,
        );
        push.sent.clear();

        await endpoints.settlement.settle(asUser(kaan), basket.id!);

        // Mert asked for nothing and there is no receipt gap: he owes
        // nothing, so he hears nothing. The shopper is owed, not owing.
        expect(push.tokens, ['phone-Ayşe']);
        expect(
          push.sent.single.message.body,
          "You owe Kaan ₺84.50 for today's run.",
        );
      });
    });

    group('registering a phone', () {
      test('twice is once', () async {
        await endpoints.device.registerToken(asUser(kaan), 'abc');
        await endpoints.device.registerToken(asUser(kaan), 'abc');

        final rows = await DeviceToken.db.find(sessionBuilder.build());
        expect(rows, hasLength(1));
      });

      test('the token follows whoever signed in last on the phone', () async {
        await endpoints.device.registerToken(asUser(kaan), 'shared');
        await endpoints.device.registerToken(asUser(ayse), 'shared');

        final row = (await DeviceToken.db.findFirstRow(
          sessionBuilder.build(),
        ))!;
        expect(row.userId, UuidValue.fromString(ayse));
      });

      test('only your own token can be removed', () async {
        await endpoints.device.registerToken(asUser(kaan), 'mine');
        await endpoints.device.removeToken(asUser(ayse), 'mine');
        expect(await DeviceToken.db.count(sessionBuilder.build()), 1);

        await endpoints.device.removeToken(asUser(kaan), 'mine');
        expect(await DeviceToken.db.count(sessionBuilder.build()), 0);
      });

      test('an empty token is refused', () async {
        await expectLater(
          endpoints.device.registerToken(asUser(kaan), '  '),
          throwsA(
            predicate((e) => _errorOf(e) == BasketError.invalidDeviceToken),
          ),
        );
      });
    });
  });
}
