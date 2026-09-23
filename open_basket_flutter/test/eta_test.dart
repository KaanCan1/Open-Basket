import 'package:flutter_test/flutter_test.dart';
import 'package:open_basket_flutter/src/core/eta.dart';

// Kadıköy, Istanbul: Moda and Bağdat Caddesi, and one further out.
const _moda = (lat: 40.9819, lng: 29.0260);
const _bagdatCd = (lat: 40.9634, lng: 29.0772);
const _atasehir = (lat: 40.9923, lng: 29.1244);

int _suggest(({double lat, double lng}) from, ({double lat, double lng}) to) =>
    Eta.suggestMinutes(
      fromLat: from.lat,
      fromLng: from.lng,
      storeLat: to.lat,
      storeLng: to.lng,
    );

void main() {
  group('haversine', () {
    test('is zero for the same point', () {
      expect(Eta.haversineKm(40.98, 29.02, 40.98, 29.02), 0);
    });

    test('matches a known distance', () {
      // Moda to Bağdat Caddesi is about 4.7 km as the crow flies.
      final km = Eta.haversineKm(
        _moda.lat,
        _moda.lng,
        _bagdatCd.lat,
        _bagdatCd.lng,
      );
      expect(km, closeTo(4.7, 0.2));
    });

    test('is symmetric', () {
      expect(
        Eta.haversineKm(_moda.lat, _moda.lng, _atasehir.lat, _atasehir.lng),
        closeTo(
          Eta.haversineKm(_atasehir.lat, _atasehir.lng, _moda.lat, _moda.lng),
          1e-9,
        ),
      );
    });
  });

  group('suggestMinutes', () {
    test('the shop downstairs is the minimum, not zero', () {
      expect(_suggest(_moda, _moda), Eta.minMinutes);
    });

    test('a walk: 1 km by road at 5 km/h plus the aisles', () {
      // ~0.77 km straight → 1.0 km by road → 12 min walking + 5 = 17.
      const nearby = (lat: 40.9888, lng: 29.0260);
      final minutes = _suggest(_moda, nearby);
      expect(minutes, inInclusiveRange(16, 18));
    });

    test('a drive: across Kadıköy by car', () {
      // ~4.7 km straight → ~6.1 km by road → ~15 min at 25 km/h + 5 = ~20.
      final minutes = _suggest(_moda, _bagdatCd);
      expect(minutes, inInclusiveRange(18, 22));
    });

    test('just past the walking limit is a drive, and quicker', () {
      // Crossing 1.5 km by road switches to the car; the suggestion should
      // drop rather than jump, because nobody walks 20 minutes to save a
      // parking space.
      final walk = Eta.suggestMinutes(
        fromLat: 0,
        fromLng: 0,
        storeLat: 0,
        storeLng: 0.0103, // ~1.15 km straight, ~1.49 km by road
      );
      final drive = Eta.suggestMinutes(
        fromLat: 0,
        fromLng: 0,
        storeLat: 0,
        storeLng: 0.0106, // ~1.18 km straight, ~1.53 km by road
      );
      expect(drive, lessThan(walk));
    });

    test('never suggests more than the server accepts', () {
      // Istanbul to Ankara.
      expect(
        Eta.suggestMinutes(
          fromLat: 41.0,
          fromLng: 29.0,
          storeLat: 39.9,
          storeLng: 32.8,
        ),
        Eta.maxMinutes,
      );
    });

    test('is always a whole number of minutes in range', () {
      for (var i = 0; i < 50; i++) {
        final minutes = Eta.suggestMinutes(
          fromLat: 40.98,
          fromLng: 29.02,
          storeLat: 40.98 + i * 0.002,
          storeLng: 29.02,
        );
        expect(minutes, inInclusiveRange(Eta.minMinutes, Eta.maxMinutes));
      }
    });
  });
}
