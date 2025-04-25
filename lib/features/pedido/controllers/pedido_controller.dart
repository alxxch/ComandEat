import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/estado_pedido.dart';

class PedidoController extends StateNotifier<AsyncValue<EstadoPedido>> {
  PedidoController(this._pedidoId) : super(const AsyncValue.loading()) {
    _init();
  }

  final int _pedidoId;
  late RealtimeChannel _channel;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  Future<void> _init() async {
    final data = await Supabase.instance.client.from('pedidos').select('estado').eq('id', _pedidoId).single();

    state = AsyncValue.data(EstadoPedido.fromString(data['estado'] as String));

    _channel = Supabase.instance.client
        .channel('public:pedidos')
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      table: 'pedidos',
      filter: PostgresChangeFilter(
        column: 'id',
        value: _pedidoId.toString(),
        type: PostgresChangeFilterType.eq,
      ),
      callback: (payload) {
        final nuevoEstado = EstadoPedido.fromString(
          payload.newRecord?['estado'] as String,
        );
        state = AsyncValue.data(nuevoEstado);
      },
    )
      ..subscribe();
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    _subscription?.cancel();
    super.dispose();
  }
}

final pedidoControllerProvider = StateNotifierProvider.family<PedidoController, AsyncValue<EstadoPedido>, int>((ref, idPedido) => PedidoController(idPedido));
