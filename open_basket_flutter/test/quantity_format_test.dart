import 'package:flutter_test/flutter_test.dart';
import 'package:open_basket_client/open_basket_client.dart';
import 'package:open_basket_flutter/src/core/quantity_format.dart';

void main() {
  test('each unit reads the way the design writes it', () {
    expect(QuantityFormat.label(2, ItemUnit.piece), '×2');
    expect(QuantityFormat.label(1, ItemUnit.kg), '1 kg');
    expect(QuantityFormat.label(500, ItemUnit.g), '500 g');
    expect(QuantityFormat.label(2, ItemUnit.l), '2 L');
    expect(QuantityFormat.label(330, ItemUnit.ml), '330 ml');
    expect(QuantityFormat.label(1, ItemUnit.pack), '1 pack');
    expect(QuantityFormat.label(3, ItemUnit.pack), '3 packs');
  });

  test('grams and millilitres start at 500 and step by 50', () {
    expect(QuantityFormat.start(ItemUnit.g), 500);
    expect(QuantityFormat.step(ItemUnit.ml), 50);
    expect(QuantityFormat.start(ItemUnit.kg), 1);
    expect(QuantityFormat.step(ItemUnit.piece), 1);
  });

  test('the ceilings match the server', () {
    expect(QuantityFormat.max(ItemUnit.piece), 99);
    expect(QuantityFormat.max(ItemUnit.g), 5000);
  });
}
