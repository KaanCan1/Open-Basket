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
/// only for now, like the rest of the app (rule 11). The title is the
/// household, so a phone in two houses' worth of family chats still says
/// which one.
abstract final class NotificationCopy {
  static const basketOpenedType = 'basket_opened';
  static const closingSoonType = 'closing_soon';
  static const settlementReadyType = 'settlement_ready';

  /// "Kaan is heading to Migros. Add what you need in the next 10 min."
  static PushMessage basketOpened({
    required String household,
    required String shopper,
    required String? store,
    required int minutes,
    required int basketId,
  }) => PushMessage(
    title: household,
    body: store == null
        ? '$shopper is going shopping. Add what you need in the next '
              '$minutes min.'
        : '$shopper is heading to $store. Add what you need in the next '
              '$minutes min.',
    type: basketOpenedType,
    basketId: basketId,
  );

  /// "2 minutes left on the basket."
  static PushMessage closingSoon({
    required String household,
    required int basketId,
  }) => PushMessage(
    title: household,
    body: '2 minutes left on the basket.',
    type: closingSoonType,
    basketId: basketId,
  );

  /// "You owe Kaan ₺84.50 for today's run."
  static PushMessage settlementReady({
    required String household,
    required String shopper,
    required int amountMinor,
    required String currencyCode,
    required int basketId,
  }) => PushMessage(
    title: household,
    body:
        'You owe $shopper ${Money.format(amountMinor, currencyCode)} '
        "for today's run.",
    type: settlementReadyType,
    basketId: basketId,
  );
}
