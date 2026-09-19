import 'package:open_basket_server/src/auth_setup.dart';
import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

BasketError? _errorOf(Object? e) => e is OpenBasketException ? e.error : null;

Matcher _fails(BasketError error) =>
    throwsA(predicate((final e) => _errorOf(e) == error));

void main() {
  withServerpod('Given the household endpoint', (sessionBuilder, endpoints) {
    setUpAll(AuthSetup.configureForTests);

    /// A session for a different signed-in user. Households are per user, so
    /// almost every test here needs at least two.
    TestSessionBuilder asUser(String uuid) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(uuid, {}),
    );

    const kaan = '11111111-1111-4111-8111-111111111111';
    const ayse = '22222222-2222-4222-8222-222222222222';
    const deniz = '33333333-3333-4333-8333-333333333333';

    test(
      'creating a household makes you its owner and gives you a code',
      () async {
        final session = asUser(kaan);

        expect(await endpoints.household.getMine(session), isNull);

        final household = await endpoints.household.create(
          session,
          'Kaya household',
        );
        expect(household.name, 'Kaya household');
        expect(household.code, hasLength(6));
        // Rule 5 and ADR-008: lira unless somebody changes it.
        expect(household.currencyCode, 'TRY');

        expect((await endpoints.household.getMine(session))!.id, household.id);

        final members = await endpoints.household.listMembers(session);
        expect(members, hasLength(1));
        expect(members.single.role, MemberRole.owner);
      },
    );

    test('you can only be in one household at a time', () async {
      final session = asUser(kaan);
      await endpoints.household.create(session, 'First');

      await expectLater(
        endpoints.household.create(session, 'Second'),
        _fails(BasketError.alreadyInAHousehold),
      );
    });

    test('someone else joins with the code', () async {
      final owner = asUser(kaan);
      final household = await endpoints.household.create(
        owner,
        'Kaya household',
      );

      final joined = await endpoints.household.joinWithCode(
        asUser(ayse),
        household.code,
      );
      expect(joined.id, household.id);

      final members = await endpoints.household.listMembers(owner);
      expect(members, hasLength(2));
      expect(
        members.map((final m) => m.role),
        containsAll([MemberRole.owner, MemberRole.member]),
      );
    });

    test('a code is forgiving about how it was typed', () async {
      final household = await endpoints.household.create(asUser(kaan), 'Kaya');

      // Lower case with the spaces people add when reading it aloud.
      final typed = household.code.toLowerCase().split('').join(' ');
      final joined = await endpoints.household.joinWithCode(
        asUser(ayse),
        typed,
      );
      expect(joined.id, household.id);
    });

    test('a code nobody has is refused', () async {
      await expectLater(
        endpoints.household.joinWithCode(asUser(ayse), 'ZZZZZZ'),
        _fails(BasketError.unknownHouseholdCode),
      );
      await expectLater(
        endpoints.household.joinWithCode(asUser(ayse), 'nope'),
        _fails(BasketError.unknownHouseholdCode),
      );
    });

    test('rotating kills the old code and keeps the members', () async {
      final owner = asUser(kaan);
      final household = await endpoints.household.create(
        owner,
        'Kaya household',
      );
      await endpoints.household.joinWithCode(asUser(ayse), household.code);

      final rotated = await endpoints.household.rotateCode(owner);
      expect(rotated.code, isNot(household.code));

      // The message sent last week no longer works...
      await expectLater(
        endpoints.household.joinWithCode(asUser(deniz), household.code),
        _fails(BasketError.unknownHouseholdCode),
      );
      // ...and the new one does.
      await endpoints.household.joinWithCode(asUser(deniz), rotated.code);

      // Everyone already in stayed in.
      expect(await endpoints.household.listMembers(owner), hasLength(3));
    });

    test('only the owner may rotate, rename or change the currency', () async {
      final owner = asUser(kaan);
      final household = await endpoints.household.create(
        owner,
        'Kaya household',
      );
      final member = asUser(ayse);
      await endpoints.household.joinWithCode(member, household.code);

      await expectLater(
        endpoints.household.rotateCode(member),
        _fails(BasketError.notTheOwner),
      );
      await expectLater(
        endpoints.household.rename(member, 'Not yours'),
        _fails(BasketError.notTheOwner),
      );
      await expectLater(
        endpoints.household.setCurrency(member, 'USD'),
        _fails(BasketError.notTheOwner),
      );
    });

    test('a non-member cannot read another household', () async {
      // The plan's explicit requirement for this day. Being outside every
      // household and being inside a different one both have to fail.
      final owner = asUser(kaan);
      await endpoints.household.create(owner, 'Kaya household');

      final outsider = asUser(deniz);
      expect(await endpoints.household.getMine(outsider), isNull);
      await expectLater(
        endpoints.household.listMembers(outsider),
        _fails(BasketError.notAMember),
      );

      // Someone with a household of their own sees only their own.
      final other = asUser(ayse);
      final theirs = await endpoints.household.create(other, 'Other household');
      expect((await endpoints.household.getMine(other))!.id, theirs.id);
      expect(await endpoints.household.listMembers(other), hasLength(1));
    });

    test(
      'currency is stored upper-cased and drives the minor-unit count',
      () async {
        final owner = asUser(kaan);
        await endpoints.household.create(owner, 'Kaya household');

        expect(await endpoints.household.currencyMinorUnitDigits(owner), 2);

        final yen = await endpoints.household.setCurrency(owner, 'jpy');
        expect(yen.currencyCode, 'JPY');
        // Zero-decimal: the receipt gap has to split in whole units (ADR-008).
        expect(await endpoints.household.currencyMinorUnitDigits(owner), 0);

        await expectLater(
          endpoints.household.setCurrency(owner, 'Turkish lira'),
          throwsA(isA<OpenBasketException>()),
        );
      },
    );

    test(
      'notification preferences belong to the member, not the household',
      () async {
        final owner = asUser(kaan);
        final household = await endpoints.household.create(
          owner,
          'Kaya household',
        );
        final member = asUser(ayse);
        await endpoints.household.joinWithCode(member, household.code);

        final updated = await endpoints.household.setNotificationPreferences(
          member,
          basketOpened: true,
          closingSoon: false,
          settlementReady: false,
        );
        expect(updated.notifyClosingSoon, isFalse);

        final all = await endpoints.household.listMembers(owner);
        final theOwner = all.firstWhere(
          (final m) => m.role == MemberRole.owner,
        );
        expect(theOwner.notifyClosingSoon, isTrue, reason: 'untouched');
      },
    );

    test(
      'an owner who leaves hands the household to the longest-standing member',
      () async {
        final owner = asUser(kaan);
        final household = await endpoints.household.create(
          owner,
          'Kaya household',
        );
        final first = asUser(ayse);
        final second = asUser(deniz);
        await endpoints.household.joinWithCode(first, household.code);
        await endpoints.household.joinWithCode(second, household.code);

        await endpoints.household.leave(owner);

        // Never leave a household with nobody able to rotate the code.
        final members = await endpoints.household.listMembers(first);
        expect(members, hasLength(2));
        expect(
          members.firstWhere((final m) => m.role == MemberRole.owner).userId,
          UuidValue.withValidation(ayse),
        );
      },
    );

    test('leaving frees you to join somewhere else', () async {
      final session = asUser(kaan);
      await endpoints.household.create(session, 'First');
      await endpoints.household.leave(session);

      expect(await endpoints.household.getMine(session), isNull);
      await endpoints.household.create(session, 'Second');
      expect((await endpoints.household.getMine(session))!.name, 'Second');
    });
  });
}
