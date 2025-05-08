import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comandeat/core/models/plato.dart';

typedef CarritoState = Map<Plato, int>;

final carritoControllerProvider = StateNotifierProvider<CarritoController, CarritoState>((ref) => CarritoController());

class CarritoController extends StateNotifier<CarritoState> {
  CarritoController() : super(const {});

  void agregar(Plato p, [int unidades = 1]) {
    final actual = state[p] ?? 0;
    state = {...state, p: actual + unidades};
  }

  void quitarUno(Plato p) {
    final qty = (state[p] ?? 1) - 1;
    if (qty <= 0) {
      quitarPorCompleto(p);
    } else {
      state = {...state, p: qty};
    }
  }

  void quitarPorCompleto(Plato p) {
    final nueva = {...state}..remove(p);
    state = nueva;
  }

  void limpiar() => state = const {};

  void reordenar(int oldIndex, int newIndex) {
    final entries = state.entries.toList();
    final moved = entries.removeAt(oldIndex);
    entries.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, moved);
    state = {for (final e in entries) e.key: e.value};
  }

  double total() => state.entries.fold(0, (acc, e) => acc + e.key.precio * e.value);
}
