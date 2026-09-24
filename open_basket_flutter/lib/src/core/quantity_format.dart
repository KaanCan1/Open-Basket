import 'package:open_basket_client/open_basket_client.dart';

/// How much of something, the way screen 08 writes it on a row: "×2" for a
/// count, "1 kg", "500 g", "2 L", "3 packs". Units are symbols, so they are
/// the same in every language; only "pack" is a word.
abstract final class QuantityFormat {
  static String label(int quantity, ItemUnit unit) => switch (unit) {
    ItemUnit.piece => '×$quantity',
    ItemUnit.kg => '$quantity kg',
    ItemUnit.g => '$quantity g',
    ItemUnit.l => '$quantity L',
    ItemUnit.ml => '$quantity ml',
    ItemUnit.pack => quantity == 1 ? '1 pack' : '$quantity packs',
  };

  /// The short name on the unit picker.
  static String unitName(ItemUnit unit) => switch (unit) {
    ItemUnit.piece => 'pcs',
    ItemUnit.kg => 'kg',
    ItemUnit.g => 'g',
    ItemUnit.l => 'L',
    ItemUnit.ml => 'ml',
    ItemUnit.pack => 'pack',
  };

  /// One press of − or +: a gram or a millilitre at a time is nobody's
  /// idea of a quantity.
  static int step(ItemUnit unit) => switch (unit) {
    ItemUnit.g || ItemUnit.ml => 50,
    _ => 1,
  };

  /// What a new unit starts at: half a kilo of cheese, not one gram.
  static int start(ItemUnit unit) => switch (unit) {
    ItemUnit.g || ItemUnit.ml => 500,
    _ => 1,
  };

  /// The server's ceiling (`BasketEndpoint.maxQuantity`).
  static int max(ItemUnit unit) => switch (unit) {
    ItemUnit.g || ItemUnit.ml => 5000,
    _ => 99,
  };
}
