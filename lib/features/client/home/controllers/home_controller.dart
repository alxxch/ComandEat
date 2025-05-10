import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/plato.dart';
import '../../../../core/services/home_repository.dart';

class HomeController extends StateNotifier<AsyncValue<List<Plato>>> {
  HomeController(this._menuRepo) : super(const AsyncValue.loading()) {
    _cargar();
  }

  final HomeRepository _menuRepo;

  Future<void> _cargar() async {
    try {
      final platos = await _menuRepo.getPlatos();
      state = AsyncValue.data(platos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
