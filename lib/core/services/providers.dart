import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plato.dart';
import 'menu_repository.dart';
import 'pedido_repository.dart';

final mesaIdProvider = Provider<int>((_) => 1);

final pedidoRepoProvider = Provider<PedidoRepository>(
      (ref) => PedidoRepository(ref.read(mesaIdProvider)),
);

final menuRepoProvider = Provider((_) => MenuRepository());

final menuControllerProvider = FutureProvider<List<Plato>>((ref) {
  return ref.read(menuRepoProvider).obtenerPlatos();
});