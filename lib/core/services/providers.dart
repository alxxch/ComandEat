import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plato.dart';
import 'menu_repository.dart';
import 'pedido_repository.dart';
import 'notification_repository.dart';

final mesaIdProvider = StateProvider<int?>((_) => null);

final pedidoRepoProvider = Provider<PedidoRepository>((ref) {
  final mesaId = ref.watch(mesaIdProvider) ?? 0;
  // O lanza si es null: throw StateError('Mesa no inicializada');
  return PedidoRepository(mesaId);
});

final menuRepoProvider = Provider((_) => MenuRepository());

final menuControllerProvider = FutureProvider<List<Plato>>((ref) {
  return ref.read(menuRepoProvider).obtenerPlatos();
});

final notificationRepoProvider = Provider((_) => NotificationRepository());