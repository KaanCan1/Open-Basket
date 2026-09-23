import 'package:flutter/material.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/quantity_format.dart';
import '../../core/theme.dart';

/// An item's name with its quantity beside it in a small pill — "Whole milk
/// ×2", "Tomatoes 1 kg" — as every row in the design writes it (screen 08).
/// Wraps rather than truncates: a long name is still something someone asked
/// for in full.
class ItemName extends StatelessWidget {
  const ItemName({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.style,
    this.struck = false,
    super.key,
  });

  ItemName.of(
    BasketItem item, {
    required this.style,
    this.struck = false,
    super.key,
  }) : name = item.name,
       quantity = item.quantity,
       unit = item.unit;

  final String name;
  final int quantity;
  final ItemUnit unit;
  final TextStyle style;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          name,
          style: struck
              ? style.copyWith(decoration: TextDecoration.lineThrough)
              : style,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF2C2C29) : OpenBasketColors.chip,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            QuantityFormat.label(quantity, unit),
            style: OpenBasketText.money(
              style.color ?? theme.textTheme.bodyLarge!.color!,
            ).copyWith(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
