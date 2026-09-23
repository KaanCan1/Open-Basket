import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

Matcher _fails(BasketError error) =>
    throwsA(predicate((final e) => _errorOf(e) == error));

void main() {
  withServerpod('Given a household adding its stores', (
    sessionBuilder,
    endpoints,
  ) {
    setUpAll(AuthSetup.configureForTests);

    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    const kaan = '11111111-1111-4111-8111-111111111111';
    const ayse = '22222222-2222-4222-8222-222222222222';
    const mert = '33333333-3333-4333-8333-333333333333';

    Future<(TestSessionBuilder, TestSessionBuilder)> aHousehold() async {
      final owner = asUser(kaan);
      final household = await endpoints.household.create(owner, 'Kaya');
      await endpoints.household.joinWithCode(asUser(ayse), household.code);
      return (owner, asUser(ayse));
    }

    test('any member adds a store, and everyone sees it', () async {
      final (owner, member) = await aHousehold();

      final migros = await endpoints.store.add(
        member,
        '  Migros Bağdat Cd. ',
        lat: 40.9634,
        lng: 29.0772,
      );

      expect(migros.name, 'Migros Bağdat Cd.');
      expect(migros.lat, 40.9634);
      final seen = await endpoints.store.list(owner);
      expect(seen.map((s) => s.id), [migros.id]);
    });

    test('a store without a location is fine', () async {
      final (owner, _) = await aHousehold();

      final sok = await endpoints.store.add(owner, 'Şok');

      expect(sok.lat, isNull);
      expect(sok.lng, isNull);
    });

    test('the same name twice is the same store', () async {
      final (owner, member) = await aHousehold();
      final first = await endpoints.store.add(owner, 'Migros');

      final again = await endpoints.store.add(member, 'migros ');

      expect(again.id, first.id);
      expect(await endpoints.store.list(owner), hasLength(1));
    });

    test('the list is alphabetical, ignoring case', () async {
      final (owner, _) = await aHousehold();
      for (final name in ['şok', 'BİM', 'Migros', 'a101']) {
        await endpoints.store.add(owner, name);
      }

      final names = (await endpoints.store.list(owner)).map((s) => s.name);

      expect(names, ['a101', 'BİM', 'Migros', 'şok']);
    });

    test('a nameless, overlong or impossible store is refused', () async {
      final (owner, _) = await aHousehold();

      for (final call in [
        () => endpoints.store.add(owner, '   '),
        () => endpoints.store.add(owner, 'x' * 61),
        () => endpoints.store.add(owner, 'Half', lat: 40.9),
        () => endpoints.store.add(owner, 'Half', lng: 29.0),
        () => endpoints.store.add(owner, 'Off', lat: 91, lng: 0),
        () => endpoints.store.add(owner, 'Off', lat: 0, lng: 181),
      ]) {
        await expectLater(call(), _fails(BasketError.invalidStore));
      }
    });

    test('another household\'s stores never show up', () async {
      final (owner, _) = await aHousehold();
      await endpoints.store.add(owner, 'Migros');

      final outsider = asUser(mert);
      await endpoints.household.create(outsider, 'Other house');

      expect(await endpoints.store.list(outsider), isEmpty);
    });

    test('removing a store keeps the baskets that used it', () async {
      final (owner, member) = await aHousehold();
      final migros = await endpoints.store.add(owner, 'Migros');
      final basket = await endpoints.basket.open(
        owner,
        storeId: migros.id,
        durationMinutes: 10,
      );
      await endpoints.basket.cancel(owner, basket.id!);

      await endpoints.store.remove(member, migros.id!);

      expect(await endpoints.store.list(owner), isEmpty);
      final kept = await Basket.db.findById(sessionBuilder.build(), basket.id!);
      expect(kept, isNotNull);
      expect(kept!.storeId, isNull);
    });

    test('an outsider cannot remove a store, or learn it exists', () async {
      final (owner, _) = await aHousehold();
      final migros = await endpoints.store.add(owner, 'Migros');
      final outsider = asUser(mert);
      await endpoints.household.create(outsider, 'Other house');

      await expectLater(
        endpoints.store.remove(outsider, migros.id!),
        _fails(BasketError.storeNotFound),
      );
      await expectLater(
        endpoints.store.remove(outsider, 999999),
        _fails(BasketError.storeNotFound),
      );
    });

    test('someone with no household is refused', () async {
      await expectLater(
        endpoints.store.list(asUser(mert)),
        _fails(BasketError.notAMember),
      );
    });
  });
}
