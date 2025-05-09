import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/global_providers.dart';

final llamadasProvider = StateNotifierProvider<LlamadasController, List<String>>((ref) => LlamadasController(ref));

class LlamadasController extends StateNotifier<List<String>> {
  LlamadasController(this._ref) : super([]) {
    _escucharLlamadasPendientes();
  }

  final Ref _ref;
  late RealtimeChannel _channel;

  void _escucharLlamadasPendientes() {
    _cargarInicial();

    _channel =
        Supabase.instance.client
            .channel('public:notificaciones')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              table: 'notificaciones',
              filter: PostgresChangeFilter(column: 'tipo', value: 'llamada', type: PostgresChangeFilterType.eq),
              callback: (payload) {
                if (payload.newRecord?['atendida'] == false) {
                  _procesarLlamada(payload.newRecord!);
                }
              },
            )
            .subscribe();
  }

  Future<void> _cargarInicial() async {
    final data = await Supabase.instance.client.from('notificaciones').select().eq('tipo', 'llamada').eq('atendida', false);

    for (final row in data as List) {
      _procesarLlamada(row as Map<String, dynamic>);
    }
  }

  void _procesarLlamada(Map<String, dynamic> row) {
    final mesa = row['mesa_id'];
    final mensaje = '📢 ¡Llamada de la mesa $mesa!';
    state = [...state, mensaje];
    _mostrarSnackbar(mensaje);
  }

  Future<void> marcarAtendida(int notificacionId) => Supabase.instance.client.from('notificaciones').update({'atendida': true}).eq('id', notificacionId);

  void _mostrarSnackbar(String mensaje) {
    final context = _ref.read(keyNavProvider).currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }
}
