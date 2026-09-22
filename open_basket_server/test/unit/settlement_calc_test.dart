import 'package:open_basket_server/src/generated/protocol.dart';
import 'package:open_basket_server/src/services/settlement_service.dart';
import 'package:test/test.dart';

// Member ids. Kaan shops in every test.
const kaan = 1;
const ayse = 2;
const deniz = 3;
const mert = 4;

BasketItem _item(
  int requester,
  int? price, {
  ItemStatus status = ItemStatus.picked,
}) => BasketItem(
  basketId: 7,
  requesterMemberId: requester,
  name: 'thing',
  quantity: 1,
  status: status,
  priceMinor: price,
  addedAt: DateTime.utc(2030),
);

List<SettlementLine> _settle(
  List<BasketItem> items, {
  List<int> members = const [kaan, ayse, deniz, mert],
  int? receipt,
}) => SettlementService.compute(
  basketId: 7,
  shopperMemberId: kaan,
  memberIds: members,
  items: items,
  receiptTotalMinor: receipt,
);

SettlementLine _lineFrom(List<SettlementLine> lines, int member) =>
    lines.singleWhere((l) => l.fromMemberId == member);

/// What the shopper ends up paying out of their own pocket: the receipt minus
/// everything the others hand over, plus anything the shopper hands back.
int _shopperCarries(List<SettlementLine> lines, int receipt) {
  var carried = receipt;
  for (final line in lines) {
    if (line.toMemberId == kaan) carried -= line.amountMinor;
    if (line.fromMemberId == kaan) carried += line.amountMinor;
  }
  return carried;
}

void main() {
  test('the design\'s own run: ₺248.80 of items, ₺250.80 receipt', () {
    // Screens 14 and 15: Ayşe ₺84.50, Deniz ₺63.30, Mert ₺38.00, Kaan ₺63.00,
    // fresh basil not available, ₺2.00 gap over four people.
    final lines = _settle([
      _item(ayse, 5980),
      _item(ayse, 2470),
      _item(deniz, 6330),
      _item(deniz, null, status: ItemStatus.unavailable),
      _item(mert, 3800),
      _item(kaan, 6300),
    ], receipt: 25080);

    expect(lines, hasLength(3));
    final a = _lineFrom(lines, ayse);
    expect((a.itemsMinor, a.receiptGapMinor, a.amountMinor), (8450, 50, 8500));
    expect(_lineFrom(lines, deniz).amountMinor, 6380);
    expect(_lineFrom(lines, mert).amountMinor, 3850);
    for (final line in lines) {
      expect(line.toMemberId, kaan);
      expect(line.basketId, 7);
    }
    // Kaan carries his own ₺63.00 plus his ₺0.50 share of the gap.
    expect(_shopperCarries(lines, 25080), 6350);
  });

  test('a household of one owes nobody anything', () {
    final lines = _settle(
      [_item(kaan, 1000)],
      members: const [kaan],
      receipt: 1200,
    );
    expect(lines, isEmpty);
  });

  test('three members, no receipt: everyone pays for their own', () {
    final lines = _settle(
      [_item(ayse, 1000), _item(deniz, 250), _item(kaan, 999)],
      members: const [kaan, ayse, deniz],
    );

    expect(lines, hasLength(2));
    expect(_lineFrom(lines, ayse).amountMinor, 1000);
    expect(_lineFrom(lines, ayse).receiptGapMinor, 0);
    expect(_lineFrom(lines, deniz).amountMinor, 250);
  });

  test('nothing picked and no receipt: nobody owes anybody', () {
    final lines = _settle([
      _item(ayse, null, status: ItemStatus.unavailable),
      _item(deniz, null, status: ItemStatus.unavailable),
    ]);
    expect(lines, isEmpty);
  });

  test('the shopper\'s own items create no debt', () {
    final lines = _settle([_item(kaan, 5000)], receipt: 5000);
    expect(lines, isEmpty);
  });

  test('a member who asked for nothing still owes a share of the gap', () {
    // ADR-007: $2.00 over four is $0.50 each, requested or not.
    final lines = _settle([_item(ayse, 1000)], receipt: 1200);

    final mertsLine = _lineFrom(lines, mert);
    expect(mertsLine.itemsMinor, 0);
    expect(mertsLine.receiptGapMinor, 50);
    expect(mertsLine.amountMinor, 50);
  });

  test('a gap that does not divide evenly leaves the remainder with the '
      'shopper', () {
    // 203 over four is 50 each and 3 left over. The members pay 50; the
    // shopper's share is 53.
    final lines = _settle([_item(ayse, 1000)], receipt: 1203);

    expect(_lineFrom(lines, ayse).receiptGapMinor, 50);
    expect(_lineFrom(lines, deniz).receiptGapMinor, 50);
    expect(_lineFrom(lines, mert).receiptGapMinor, 50);
    expect(_shopperCarries(lines, 1203), 53);
  });

  test('a zero-decimal currency splits in whole units', () {
    // ¥1,000 of items, ¥1,003 at the till: whole yen, nothing smaller exists.
    final lines = _settle([
      _item(ayse, 400),
      _item(deniz, 600),
    ], receipt: 1003);

    for (final line in lines) {
      expect(line.receiptGapMinor, 0, reason: '3 yen over 4 is 0 each');
    }
    expect(_lineFrom(lines, ayse).amountMinor, 400);
    expect(_shopperCarries(lines, 1003), 3);
  });

  test('a till that charged less is a credit to everyone', () {
    // ₺2.00 discount over four: each member's debt drops by ₺0.50.
    final lines = _settle([_item(ayse, 1000)], receipt: 800);

    expect(_lineFrom(lines, ayse).amountMinor, 950);
    expect(_lineFrom(lines, ayse).receiptGapMinor, -50);
  });

  test('a credit bigger than someone\'s items flips the line', () {
    // Deniz asked for nothing and the till charged ₺2.00 less, so Kaan owes
    // Deniz ₺0.50, not the other way round, and the amount stays positive.
    final lines = _settle([_item(ayse, 1000)], receipt: 800);

    final toDeniz = lines.singleWhere((l) => l.toMemberId == deniz);
    expect(toDeniz.fromMemberId, kaan);
    expect(toDeniz.amountMinor, 50);
    expect(toDeniz.itemsMinor, 0);
    expect(toDeniz.receiptGapMinor, 50);
  });

  test('unpriced and requested items count as nothing', () {
    // `settle` refuses these; `preview` has to survive them.
    final lines = _settle([
      _item(ayse, null),
      _item(deniz, 900, status: ItemStatus.requested),
      _item(mert, 300),
    ]);

    expect(lines.map((l) => l.fromMemberId), [mert]);
  });

  test('every line always balances: amount = items + gap', () {
    for (var receipt = 900; receipt <= 1100; receipt += 7) {
      final lines = _settle([
        _item(ayse, 400),
        _item(deniz, 350),
        _item(kaan, 250),
      ], receipt: receipt);
      for (final line in lines) {
        expect(line.amountMinor, line.itemsMinor + line.receiptGapMinor);
        expect(line.amountMinor, isPositive);
      }
    }
  });

  test('an item from someone who has left lands on the shopper', () {
    final lines = _settle(
      [_item(99, 500), _item(ayse, 500)],
      members: const [kaan, ayse],
      receipt: 1000,
    );

    expect(lines, hasLength(1));
    expect(_lineFrom(lines, ayse).amountMinor, 500);
    expect(_shopperCarries(lines, 1000), 500);
  });

  test('the shopper has to be one of the members', () {
    expect(
      () => SettlementService.compute(
        basketId: 7,
        shopperMemberId: kaan,
        memberIds: const [ayse],
        items: const [],
      ),
      throwsArgumentError,
    );
  });
}
