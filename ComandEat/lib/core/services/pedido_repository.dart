import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plato.dart';

class PedidoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int> enviarPedido(Map<Plato, int> carrito, int mesaId) async {
    final cabecera = await _client
        .from('pedidos')
        .insert({'mesa_id': mesaId})
        .select()
        .single();
    final pedidoId = cabecera['id'] as int;

    final lineas = carrito.entries.map((e) {
      return {
        'pedido_id': pedidoId,
        'plato_id': e.key.id,
        'cantidad': e.value,
        'precio_unidad': e.key.precio,
      };
    }).toList();

    await _client.from('pedido_detalle').insert(lineas);

    return pedidoId;
  }
}