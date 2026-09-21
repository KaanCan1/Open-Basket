import 'package:clock/clock.dart' as pkg;

/// The server's clock.
///
/// Rule 1: the server owns time. Every "now" on the server is read here, so a
/// test can decide what now means instead of waiting for it — `auto_close_test`
/// opens a five minute basket, moves the clock six minutes on and fires the
/// future call, which exercises the real scheduling path rather than editing
/// `closesAt` in the database by hand.
///
/// This is a thin wrapper over `package:clock` rather than a global of our
/// own. `withClock` is scoped to the zone it wraps, so a test cannot leak a
/// frozen clock into the test that runs after it, and Serverpod's own future
/// call manager already reads the same source.
///
/// Always UTC. `closesAt` is stored and compared in UTC, and a server that
/// answered `getServerTime` in local time would hand the client a drift
/// correction wrong by the timezone offset.
abstract final class ServerClock {
  /// The current time, in UTC.
  static DateTime now() => pkg.clock.now().toUtc();
}
