import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/client/home/controllers/home_controller.dart';
import '../../features/client/pedido/controllers/pedido_controller.dart';
import '../models/estado_pedido.dart';
import '../models/plato.dart';
import 'home_repository.dart';
import 'pedido_repository.dart';
import 'notification_repository.dart';

final mesaIdProvider = StateProvider<int?>((_) => null);

final pedidoRepoProvider = Provider<PedidoRepository>((ref) {
  final mesaId = ref.watch(mesaIdProvider) ?? 0;
  return PedidoRepository(mesaId);
});

final pedidoControllerProvider =
StateNotifierProvider.family<PedidoController, AsyncValue<EstadoPedido>, int>(
      (ref, pedidoId) => PedidoController(pedidoId),
);

final menuRepoProvider = Provider((_) => HomeRepository());

final menuControllerProvider =
    StateNotifierProvider<HomeController, AsyncValue<List<Plato>>>((ref) {
      final repo = ref.read(menuRepoProvider);
      return HomeController(repo);
    });

final notificationRepoProvider = Provider((_) => NotificationRepository());

final notificacionesCountProvider = FutureProvider<int>((ref) async {
  final sql = Supabase.instance.client;
  final notis = await sql.from('notificaciones').select('id');
  final lstNotis = notis as List<dynamic>;
  return lstNotis.length;
});
