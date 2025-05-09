import 'package:comandeat/core/models/plato.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CarritoState = Map<Plato, int>;

final carritoControllerProvider = StateNotifierProvider<CarritoController, CarritoState>(
  (ref) => CarritoController(),
);

class CarritoController extends StateNotifier<CarritoState> {
  CarritoController() : super(const {});

  void addPlato(Plato plato, [int unidades = 1]) {
    final platoActu = state[plato] ?? 0;
    state = {...state, plato: platoActu + unidades};
  }

  void delete1Plato(Plato plato) {
    final cantidad = (state[plato] ?? 1) - 1;
    if (cantidad <= 0) {
      quitarPorCompleto(plato);
    } else {
      state = {...state, plato: cantidad};
    }
  }

  void quitarPorCompleto(Plato plato) {
    final quitado = {...state}..remove(plato);
    state = quitado;
  }

  void clean() => state = const {};

  void reordenar(int oldIndex, int newIndex) {
    final platos = state.entries.toList();
    final platoMover = platos.removeAt(oldIndex);
    platos.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, platoMover);
    state = {for (final e in platos) e.key: e.value};
  }

  double total() =>
      state.entries.fold(0, (valorAcum, e) => valorAcum + e.key.precio * e.value);
}
