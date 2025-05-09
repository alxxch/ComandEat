import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plato.dart';
import 'menu_repository.dart';
import 'pedido_repository.dart';
import 'notification_repository.dart';

final mesaIdProvider = StateProvider<int?>((_) => null);

final pedidoRepoProvider = Provider<PedidoRepository>((ref) {
  final mesaId = ref.watch(mesaIdProvider) ?? 0;
  return PedidoRepository(mesaId);
});

final menuRepoProvider = Provider((_) => MenuRepository());

final menuControllerProvider = FutureProvider<List<Plato>>((ref) {
  return ref.read(menuRepoProvider).obtenerPlatos();
});

final notificationRepoProvider = Provider((_) => NotificationRepository());

final notificacionesCountProvider = FutureProvider<int>((ref) async {
  final sql = Supabase.instance.client;
  final notis = await sql.from('notificaciones').select('id');
  final lstNotis = notis as List<dynamic>;
  return lstNotis.length;
});
