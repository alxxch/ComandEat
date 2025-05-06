import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/pedido.dart';

final pedidosAdminProvider = StateNotifierProvider<PedidosController, List<Pedido>>((ref) => PedidosController());

class PedidosController extends StateNotifier<List<Pedido>> {
  PedidosController() : super([]) {
    _init();
  }

  late RealtimeChannel _channel;

  void _init() {
    _channel =
        Supabase.instance.client
            .channel('public:pedidos')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              table: 'pedidos',
              callback: (payload) {
                final nuevo = Pedido.fromJson(payload.newRecord!);
                state = [...state, nuevo];
              },
            )
            .subscribe();
  }

  Future<void> actualizarEstado(int pedidoId, EstadoPedido nuevoEstado) async {
    await Supabase.instance.client.from('pedidos').update({'estado': nuevoEstado.name.toUpperCase()}).eq('id', pedidoId);
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }
}
