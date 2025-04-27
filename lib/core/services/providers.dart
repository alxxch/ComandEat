import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_repository.dart';
import 'pedido_repository.dart';

final mesaIdProvider = Provider<int>((_) => 1);

final pedidoRepoProvider = Provider<PedidoRepository>(
      (ref) => PedidoRepository(ref.read(mesaIdProvider)),
);

final menuRepoProvider = Provider<MenuRepository>((_) => MenuRepository());