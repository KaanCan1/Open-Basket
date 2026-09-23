import 'dart:math' as math;

/// How long a run to a store probably takes, from where the shopper is now.
///
/// Computed on the phone (ADR-002): the shopper's position is read once, fed
/// in here, and thrown away. Only the store and the chosen number of minutes
/// ever reach the server.
///
/// The basket closes at the checkout, so this is the way there plus the time
/// spent in the aisles — not the way home.
abstract final class Eta {
  /// Straight lines are shorter than streets. 1.3 is the usual urban
  /// detour factor.
  static const roadFactor = 1.3;

  /// Up to this far by road, people walk.
  static const walkingLimitKm = 1.5;
  static const walkingKmh = 5.0;

  /// City traffic, parking included, not the speed limit.
  static const drivingKmh = 25.0;

  /// Finding things, the queue at the till.
  static const shoppingBufferMinutes = 5;

  /// The server refuses anything outside 1..120 (BasketService); a
  /// suggestion below five minutes is not a run anyone makes.
  static const minMinutes = 5;
  static const maxMinutes = 120;

  /// Great-circle distance in kilometres.
  static double haversineKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;
    double rad(double deg) => deg * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
  }

  /// Suggested basket length in whole minutes, from the shopper at
  /// ([fromLat], [fromLng]) to a store at ([storeLat], [storeLng]).
  static int suggestMinutes({
    required double fromLat,
    required double fromLng,
    required double storeLat,
    required double storeLng,
  }) {
    final roadKm =
        haversineKm(fromLat, fromLng, storeLat, storeLng) * roadFactor;
    final kmh = roadKm <= walkingLimitKm ? walkingKmh : drivingKmh;
    final travelMinutes = roadKm / kmh * 60;
    final total = (travelMinutes + shoppingBufferMinutes).ceil();
    return total.clamp(minMinutes, maxMinutes);
  }
}
