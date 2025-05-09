import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/plato.dart';
import '../../../../core/services/menu_repository.dart';

class MenuController extends StateNotifier<AsyncValue<List<Plato>>> {
  MenuController(this._menuRepo) : super(const AsyncValue.loading()) {
    _cargar();
  }

  final MenuRepository _menuRepo;

  Future<void> _cargar() async {
    try {
      final platos = await _menuRepo.getPlatos();
      state = AsyncValue.data(platos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
