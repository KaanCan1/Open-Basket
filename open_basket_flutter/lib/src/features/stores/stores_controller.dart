import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../core/client_provider.dart';

/// The household's stores, alphabetically.
final storesProvider = FutureProvider<List<Store>>((final ref) async {
  if (ref.watch(sessionUserProvider) == null) return const [];
  return ref.watch(clientProvider).store.list();
});

class StoresController {
  const StoresController(this._ref);

  final Ref _ref;

  Future<Store> add(String name, {double? lat, double? lng}) async {
    final store = await _ref
        .read(clientProvider)
        .store
        .add(name, lat: lat, lng: lng);
    _ref.invalidate(storesProvider);
    return store;
  }

  Future<void> remove(int storeId) async {
    await _ref.read(clientProvider).store.remove(storeId);
    _ref.invalidate(storesProvider);
  }
}

final storesControllerProvider = Provider<StoresController>(
  StoresController.new,
);
