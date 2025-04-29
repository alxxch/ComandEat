import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> llamarCamarero(int mesaId) {
    return _client.from('notificaciones').insert({
      'mesa_id'    : mesaId,
      'tipo'       : 'llamada',
      'atendida'   : false,
    });
  }
}