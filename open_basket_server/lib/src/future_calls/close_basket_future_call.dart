import 'package:serverpod/serverpod.dart';

import '../services/basket_service.dart';

/// Closes a basket when its time runs out.
///
/// This is the reason the app needs a server at all. The basket closes whether
/// or not anyone's phone is awake, in a tunnel, or switched off — which no
/// amount of client-side timer can promise.
///
/// Scheduled by `BasketEndpoint.open` and rescheduled by `extend`. The work
/// itself is idempotent (rule 2): `closeIfDue` reloads the basket and does
/// nothing unless it is still `open` and genuinely overdue, so a call left
/// over from before an extension fires harmlessly.
class CloseBasketFutureCall extends FutureCall {
  Future<void> close(Session session, int basketId) async {
    final closed = await BasketService.closeIfDue(session, basketId);
    if (closed == null) {
      session.log(
        'close for basket $basketId was already handled; nothing to do',
        level: LogLevel.debug,
      );
    }
  }
}
