import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plato.dart';

class PedidoRepository {
  final int mesaId;

  PedidoRepository(this.mesaId);

  final SupabaseClient _client = Supabase.instance.client;

  Future<int> sendPedido(Map<Plato, int> carrito) async {
    if (carrito.isEmpty) throw Exception('Carrito vacío');
    final pedidoEnviado =
        await _client
            .from('pedidos')
            .insert({'mesa_id': mesaId, 'estado': 'PENDIENTE'})
            .select('id')
            .single();
    final pedidoId = pedidoEnviado['id'] as int;
    final pedidoDetalles =
        carrito.entries
            .map(
              (e) => {
                'pedido_id': pedidoId,
                'plato_id': e.key.id,
                'cantidad': e.value,
                'precio_unidad': e.key.precio,
              },
            )
            .toList();
    await _client.from('pedido_detalle').insert(pedidoDetalles);
    return pedidoId;
  }
}
