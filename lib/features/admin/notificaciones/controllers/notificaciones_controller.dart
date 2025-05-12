import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/notificacion.dart';

class NotificacionesController extends ChangeNotifier {
  Future<List<Notificacion>> lstNotis = Future.value([]);

  NotificacionesController() {
    fetchNotificaciones();
  }

  Future<List<Notificacion>> _getNotificaciones() async {
    final sql = Supabase.instance.client;
    try {
      final notis = await sql
          .from('notificaciones')
          .select('id, mesa_id, tipo, fecha_hora, atendida')
          .order('fecha_hora', ascending: false);
      return (notis as List<dynamic>)
          .map((e) => Notificacion.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error cargando notificaciones: $e');
    }
  }

  void fetchNotificaciones() {
    lstNotis = _getNotificaciones();
    notifyListeners();
  }

  Future<void> marcarAtendida(Notificacion noti) async {
    final sql = Supabase.instance.client;
    await sql
        .from('notificaciones')
        .update({'atendida': true})
        .eq('id', noti.id)
        .select();
    fetchNotificaciones();
  }

  Future<void> eliminarTodas() async {
    final sql = Supabase.instance.client;
    await sql.from('notificaciones').delete().eq('tipo', 'llamada').select();
    fetchNotificaciones();
  }
}
