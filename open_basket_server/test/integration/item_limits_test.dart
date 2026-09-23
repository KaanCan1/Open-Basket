import 'package:clock/clock.dart';
import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/endpoints/basket_endpoint.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

Matcher _fails(BasketError error) =>
    throwsA(predicate((final e) => _errorOf(e) == error));

void main() {
  withServerpod('Given people adding items', (sessionBuilder, endpoints) {
    setUpAll(AuthSetup.configureForTests);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    const kaan = '11111111-1111-4111-8111-111111111111';
    const ayse = '22222222-2222-4222-8222-222222222222';

    Future<(TestSessionBuilder, TestSessionBuilder, Basket)> aBasket() async {
      final shopper = asUser(kaan);
      final household = await endpoints.household.create(shopper, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      final basket = await endpoints.basket.open(
        shopper,
        durationMinutes: 120,
      );
      return (shopper, asUser(ayse), basket);
    }

    test('more than a person types in a minute is refused', () async {
      final (_, member, basket) = await aBasket();
      for (var i = 0; i < BasketEndpoint.maxItemsPerMinute; i++) {
        await endpoints.basket.addItem(member, basket.id!, 'Thing $i');
      }

      await expectLater(
        endpoints.basket.addItem(member, basket.id!, 'One more'),
        _fails(BasketError.tooManyItems),
      );
    });

    test('the limit is per person, not per household', () async {
      final (shopper, member, basket) = await aBasket();
      for (var i = 0; i < BasketEndpoint.maxItemsPerMinute; i++) {
        await endpoints.basket.addItem(member, basket.id!, 'Thing $i');
      }

      // Ayşe is out of breath; Kaan is not.
      final item = await endpoints.basket.addItem(shopper, basket.id!, 'Bread');
      expect(item.name, 'Bread');
    });

    test('a slow, long list still stops at the per-basket cap', () async {
      final (_, member, basket) = await aBasket();
      final start = DateTime.now().toUtc();
      for (var i = 0; i < BasketEndpoint.maxItemsPerMember; i++) {
        // A minute apart, so only the per-basket cap can be what stops it.
        await withClock(
          Clock.fixed(start.add(Duration(minutes: i))),
          () => endpoints.basket.addItem(member, basket.id!, 'Thing $i'),
        );
      }

      await expectLater(
        withClock(
          Clock.fixed(start.add(const Duration(hours: 1))),
          () => endpoints.basket.addItem(member, basket.id!, 'One more'),
        ),
        _fails(BasketError.tooManyItems),
      );
    });

    test('suggestions are what I ask for again and again', () async {
      final (shopper, member, _) = await aBasket();
      // Three past runs: milk every time, bread twice, basil once.
      expect(await endpoints.history.list(shopper), isEmpty);
      for (var run = 0; run < 3; run++) {
        final active = await endpoints.basket.getActive(shopper);
        final basket =
            active ?? await endpoints.basket.open(shopper, durationMinutes: 10);
        await endpoints.basket.addItem(member, basket.id!, 'Milk');
        if (run < 2) {
          await endpoints.basket.addItem(member, basket.id!, 'bread');
        }
        if (run == 2) {
          await endpoints.basket.addItem(member, basket.id!, 'Basil');
        }
        await endpoints.basket.cancel(shopper, basket.id!);
      }
      // Kaan's own requests are not Ayşe's suggestions.
      final another = await endpoints.basket.open(shopper, durationMinutes: 10);
      await endpoints.basket.addItem(shopper, another.id!, 'Coffee');
      await endpoints.basket.addItem(shopper, another.id!, 'Coffee');

      final suggested = await endpoints.basket.suggestions(member);

      expect(suggested, ['Milk', 'bread']);
      expect(await endpoints.basket.suggestions(member, limit: 1), ['Milk']);
      expect(await endpoints.basket.suggestions(shopper), ['Coffee']);
    });

    group('units (screen 09)', () {
      test(
        'an item is counted in pieces unless someone says otherwise',
        () async {
          final (_, member, basket) = await aBasket();
          final eggs = await endpoints.basket.addItem(
            member,
            basket.id!,
            'Eggs',
            quantity: 10,
          );
          expect(eggs.unit, ItemUnit.piece);
          expect(eggs.quantity, 10);
        },
      );

      test('weights and volumes keep their unit', () async {
        final (_, member, basket) = await aBasket();
        final tomatoes = await endpoints.basket.addItem(
          member,
          basket.id!,
          'Tomatoes',
          quantity: 1,
          unit: ItemUnit.kg,
        );
        final cheese = await endpoints.basket.addItem(
          member,
          basket.id!,
          'Cheese',
          quantity: 250,
          unit: ItemUnit.g,
        );
        expect(tomatoes.unit, ItemUnit.kg);
        expect(cheese.quantity, 250);
        expect(cheese.unit, ItemUnit.g);
      });

      test('the range follows the unit: 500 is grams, not kilos', () async {
        final (_, member, basket) = await aBasket();
        await expectLater(
          endpoints.basket.addItem(
            member,
            basket.id!,
            'Flour',
            quantity: 500,
            unit: ItemUnit.kg,
          ),
          _fails(BasketError.invalidItem),
        );
        await expectLater(
          endpoints.basket.addItem(
            member,
            basket.id!,
            'Flour',
            quantity: 5001,
            unit: ItemUnit.g,
          ),
          _fails(BasketError.invalidItem),
        );
      });

      test('changing the unit re-checks the quantity it keeps', () async {
        final (_, member, basket) = await aBasket();
        final flour = await endpoints.basket.addItem(
          member,
          basket.id!,
          'Flour',
          quantity: 500,
          unit: ItemUnit.g,
        );
        await expectLater(
          endpoints.basket.updateItem(member, flour.id!, unit: ItemUnit.kg),
          _fails(BasketError.invalidItem),
        );
        final kilo = await endpoints.basket.updateItem(
          member,
          flour.id!,
          quantity: 1,
          unit: ItemUnit.kg,
        );
        expect(kilo.unit, ItemUnit.kg);
        expect(kilo.quantity, 1);
      });
    });
  });
}
