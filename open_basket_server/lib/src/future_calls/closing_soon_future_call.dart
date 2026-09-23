import 'package:serverpod/serverpod.dart';

import '../services/notification_service.dart';

/// "2 minutes left on the basket", to the members who have not added
/// anything yet.
///
/// Scheduled next to the close by `BasketService.scheduleClose`, and replaced
/// with it on an extension. Idempotent like the close (rule 2):
/// `NotificationService.closingSoon` reloads the basket and does nothing
/// unless it is still open and about two minutes from closing, so a reminder
/// left over from before an extension fires harmlessly.
class ClosingSoonFutureCall extends FutureCall {
  Future<void> remind(Session session, int basketId) async {
    await NotificationService.closingSoon(session, basketId);
  }
}
