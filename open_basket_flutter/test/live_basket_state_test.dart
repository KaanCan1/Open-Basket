import 'package:flutter_test/flutter_test.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:open_basket_flutter/src/features/basket/live_basket_state.dart';

BasketItem _item(int id, {String name = 'Milk', int quantity = 1}) {
  return BasketItem(
    id: id,
    basketId: 1,
    requesterMemberId: 7,
    name: name,
    quantity: quantity,
    status: ItemStatus.requested,
    addedAt: DateTime.utc(2030),
  );
}

void main() {
  const live = LiveBasketState(connection: LiveConnection.live);

  group('applying item events', () {
    test('a new item is appended', () {
      final state = live.withItem(_item(1)).withItem(_item(2, name: 'Eggs'));
      expect(state.items.map((final i) => i.name), ['Milk', 'Eggs']);
    });

    test('the same item twice does not double it', () {
      // ADR-016: the server subscribes before it reads the snapshot, so an
      // itemAdded for a row the snapshot already carried is normal. Appending
      // would show the milk twice. Dropping events is unrecoverable;
      // applying one twice must not be.
      final state = live.withItem(_item(1)).withItem(_item(1));
      expect(state.items, hasLength(1));
    });

    test('a repeat replaces rather than ignores', () {
      // The second copy may be newer — an itemUpdated arriving after a
      // snapshot that predates it.
      final state = live
          .withItem(_item(1, name: 'Milk'))
          .withItem(_item(1, name: 'Milk, 1L', quantity: 3));
      expect(state.items.single.name, 'Milk, 1L');
      expect(state.items.single.quantity, 3);
    });

    test('order is held across a replacement', () {
      final state = live
          .withItem(_item(1, name: 'Milk'))
          .withItem(_item(2, name: 'Eggs'))
          .withItem(_item(1, name: 'Milk, 1L'));
      expect(state.items.map((final i) => i.name), ['Milk, 1L', 'Eggs']);
    });

    test('removing takes out only that item', () {
      final state = live
          .withItem(_item(1, name: 'Milk'))
          .withItem(_item(2, name: 'Eggs'))
          .withoutItem(1);
      expect(state.items.map((final i) => i.name), ['Eggs']);
    });

    test('removing something already gone is harmless', () {
      final state = live.withItem(_item(1)).withoutItem(99);
      expect(state.items, hasLength(1));
    });
  });
}
