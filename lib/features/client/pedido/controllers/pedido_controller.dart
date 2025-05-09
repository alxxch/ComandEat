import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/estado_pedido.dart';

class PedidoController extends StateNotifier<AsyncValue<EstadoPedido>> {
  PedidoController(this._pedidoId) : super(const AsyncValue.loading()) {
    _init();
  }

  final int _pedidoId;
  late RealtimeChannel _channel;

  Future<void> _init() async {
    final sql =
        await Supabase.instance.client
            .from('pedidos')
            .select('estado')
            .eq('id', _pedidoId)
            .maybeSingle();
    if (sql == null) {
      state = AsyncValue.error('Pedido no encontrado', StackTrace.current);
      return;
    }
    state = AsyncValue.data(EstadoPedidoX.fromString(sql['estado'] as String));
    _channel =
        Supabase.instance.client
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
                final newState = payload.newRecord['estado'] as String?;
                if (newState != null) {
                  state = AsyncValue.data(EstadoPedidoX.fromString(newState));
                }
              },
            )
            .subscribe();
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }
}
