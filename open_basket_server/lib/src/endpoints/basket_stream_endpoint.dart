import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// The live basket.
class BasketStreamEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Channel name for a basket's events. Everything that mutates a basket
  /// posts here through `session.messages.postMessage`, and every watcher
  /// picks it up through `session.messages.createStream`.
  static String channelFor(int basketId) => 'basket:$basketId';

  /// Watches one basket.
  ///
  /// The first event is always a `snapshot` carrying the basket and all of its
  /// items, so a client that dropped its connection resyncs from the stream
  /// itself and never needs a second call. Every event carries `serverTime`.
  ///
  /// Throws `notAMember` before yielding anything.
  Stream<BasketEvent> watch(Session session, int basketId) async* {
    throw UnimplementedError('Day 9');
  }
}
