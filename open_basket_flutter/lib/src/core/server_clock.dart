import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The server's clock, as this device can best tell it.
///
/// Rule 1: the server owns time. A countdown rendered from `DateTime.now()`
/// is wrong by however far this phone's clock has drifted, and a phone whose
/// clock is two minutes fast shows a basket closing two minutes early — which
/// looks exactly like the server losing the basket.
///
/// So nothing reads the device clock directly. This holds the offset between
/// the two and hands out a corrected now. The offset is seeded once on connect
/// and then refreshed from every stream event, because each one carries the
/// server's time for precisely this purpose.
class ServerClock {
  Duration _offset = Duration.zero;

  /// How far this device is behind the server. Positive means the phone is
  /// slow. Exposed for the diagnostics line, not for arithmetic.
  Duration get offset => _offset;

  DateTime now() => DateTime.now().toUtc().add(_offset);

  /// Records a reading. [serverTime] is what the server said "now" was when
  /// it sent the event.
  ///
  /// The round trip is not corrected for: a reading arrives some milliseconds
  /// after the server took it, so this runs slightly slow. At second
  /// granularity on a countdown that is not worth the complexity of measuring
  /// latency, and erring slow is the right direction — better to show one
  /// second left than to show a basket closed that is still open.
  void reconcile(DateTime serverTime) {
    _offset = serverTime.toUtc().difference(DateTime.now().toUtc());
  }
}

/// Nothing seeds this at startup on purpose. The only screen with a countdown
/// is the live basket, and it shows a spinner until the stream's first event
/// arrives — which is a snapshot carrying `serverTime`. So the clock is always
/// reconciled before a countdown is drawn, and `getServerTime` is there for a
/// screen that needs the time without a stream behind it.
final serverClockProvider = Provider<ServerClock>((final _) => ServerClock());
