import 'package:geolocator/geolocator.dart';

/// A position, for the moment it is needed and no longer.
typedef Position2D = ({double lat, double lng});

/// Reads the phone's position once (rule 7, ADR-002).
///
/// Never streams, never stores, never logs, never sends: the caller uses the
/// result for one calculation or one store pin and drops it. Every failure —
/// services off, permission refused, no fix in time — is a quiet null, and
/// the caller falls back to a manual duration without making a fuss.
abstract final class LocationOnce {
  static Future<Position2D?> read() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // A store is a building, a run is minutes: a hundred metres is
          // plenty, and it is quicker and kinder to the battery than best.
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return (lat: position.latitude, lng: position.longitude);
    } catch (_) {
      return null;
    }
  }
}
