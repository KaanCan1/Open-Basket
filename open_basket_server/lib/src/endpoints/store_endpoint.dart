import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/authz.dart';

/// Shops the household uses. Only a store's own fixed location is ever stored;
/// nobody's live position reaches the server (ADR-002).
///
/// Any member may add or remove a store: it is a shared list, like the one on
/// the fridge, and the design offers "Add a store" to everyone who opens a
/// basket.
class StoreEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const maxNameLength = 60;

  /// `lat`/`lng` are null when the member skipped the location step, in which
  /// case the client stops suggesting a duration and defaults to 10 minutes.
  ///
  /// Adding a name the household already has (ignoring case and surrounding
  /// space) returns the existing store rather than a second "Migros": two
  /// chips with the same name and different ids is a choice nobody can make.
  Future<Store> add(
    Session session,
    String name, {
    double? lat,
    double? lng,
  }) async {
    final member = await Authz.requireMember(session);
    final cleaned = name.trim();
    if (cleaned.isEmpty || cleaned.length > maxNameLength) {
      throw _invalid('Give the store a name.');
    }
    if ((lat == null) != (lng == null)) {
      throw _invalid('A location needs both coordinates.');
    }
    if (lat != null && !_isPlace(lat, lng!)) {
      throw _invalid('That location is not a place on Earth.');
    }

    final existing = await _named(session, member.householdId, cleaned);
    if (existing != null) return existing;

    return Store.db.insertRow(
      session,
      Store(
        householdId: member.householdId,
        name: cleaned,
        lat: lat,
        lng: lng,
      ),
    );
  }

  /// The household's stores, alphabetically — the order the chips appear in.
  Future<List<Store>> list(Session session) async {
    final member = await Authz.requireMember(session);
    final stores = await Store.db.find(
      session,
      where: (t) => t.householdId.equals(member.householdId),
    );
    // Sorted here rather than in SQL so "şok" and "Şok" sort together:
    // Postgres collation on the server is not the phone's.
    stores.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return stores;
  }

  /// Baskets that already used this store keep working: the relation is
  /// `onDelete=SetNull`, so history does not lose its rows.
  Future<void> remove(Session session, int storeId) async {
    final member = await Authz.requireMember(session);
    final store = await Store.db.findById(session, storeId);
    if (store == null || store.householdId != member.householdId) {
      throw OpenBasketException(
        error: BasketError.storeNotFound,
        message: 'That store is not in your household.',
      );
    }
    await Store.db.deleteRow(session, store);
  }

  Future<Store?> _named(Session session, int householdId, String name) async {
    final stores = await Store.db.find(
      session,
      where: (t) => t.householdId.equals(householdId),
    );
    final wanted = name.toLowerCase();
    for (final store in stores) {
      if (store.name.toLowerCase() == wanted) return store;
    }
    return null;
  }

  static bool _isPlace(double lat, double lng) =>
      lat.isFinite &&
      lng.isFinite &&
      lat >= -90 &&
      lat <= 90 &&
      lng >= -180 &&
      lng <= 180;

  OpenBasketException _invalid(String message) =>
      OpenBasketException(error: BasketError.invalidStore, message: message);
}
