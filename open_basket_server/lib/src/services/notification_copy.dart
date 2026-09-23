import '../util/money.dart';

/// One push: what the lock screen shows, plus where a tap should land.
class PushMessage {
  const PushMessage({
    required this.title,
    required this.body,
    required this.type,
    required this.basketId,
  });

  final String title;
  final String body;

  /// `basket_opened`, `closing_soon` or `settlement_ready`; the app uses it
  /// with [basketId] to open the right screen.
  final String type;
  final int basketId;

  Map<String, String> get data => {'type': type, 'basketId': '$basketId'};
}

/// Every word a notification says, in one place (plan, Days 11-12), so a
/// second language is a second copy of this file and nothing else. English
/// only for now, like the rest of the app (rule 11).
///
/// Worded as screen 21 of the design has them on a lock screen: the title
/// says what happened, the body what to do about it or why the number is
/// what it is. The app's own name is the notification's header, so it is not
/// repeated here.
abstract final class NotificationCopy {
  static const basketOpenedType = 'basket_opened';
  static const closingSoonType = 'closing_soon';
  static const settlementReadyType = 'settlement_ready';

  /// "Kaan is heading to Migros" / "Add what you need in the next 10 min."
  static PushMessage basketOpened({
    required String shopper,
    required String? store,
    required int minutes,
    required int basketId,
  }) => PushMessage(
    title: store == null
        ? '$shopper is going shopping'
        : '$shopper is heading to $store',
    body: 'Add what you need in the next $minutes min.',
    type: basketOpenedType,
    basketId: basketId,
  );

  /// "2 minutes left on the basket" / "Last chance to add something to
  /// Kaan's run."
  static PushMessage closingSoon({
    required String shopper,
    required int basketId,
  }) => PushMessage(
    title: '2 minutes left on the basket',
    body: "Last chance to add something to $shopper's run.",
    type: closingSoonType,
    basketId: basketId,
  );

  /// "You owe Kaan ₺85.00" / "₺84.50 of items plus ₺0.50 of the receipt
  /// gap." The body is how the number was reached, from the line itself.
  static PushMessage settlementReady({
    required String shopper,
    required int amountMinor,
    required int itemsMinor,
    required int receiptGapMinor,
    required String currencyCode,
    required int basketId,
  }) {
    String money(int minor) => Money.format(minor, currencyCode);
    final items = '${money(itemsMinor)} of items';
    return PushMessage(
      title: 'You owe $shopper ${money(amountMinor)}',
      body: switch (receiptGapMinor) {
        0 => '$items.',
        > 0 => '$items plus ${money(receiptGapMinor)} of the receipt gap.',
        _ => '$items less ${money(-receiptGapMinor)} the receipt came under.',
      },
      type: settlementReadyType,
      basketId: basketId,
    );
  }
}
