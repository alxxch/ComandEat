import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/plato.dart';
import '../../../../core/services/menu_repository.dart';

class MenuController extends StateNotifier<AsyncValue<List<Plato>>> {
  MenuController(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final MenuRepository _repo;

  Future<void> _load() async {
    try {
      final platos = await _repo.obtenerPlatos();
      state = AsyncValue.data(platos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final menuControllerProvider =
StateNotifierProvider<MenuController, AsyncValue<List<Plato>>>(
      (ref) {
    final repo = ref.read(menuRepoProvider);
    return MenuController(repo);
  },
);

final menuRepoProvider = Provider((_) => MenuRepository());
