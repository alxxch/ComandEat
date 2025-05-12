import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/reserva.dart';


class ReservasController extends ChangeNotifier {
  Future<List<Reserva>> lstReservas = Future.value([]);

  ReservasController() {
    fetchReservas();
  }

  Future<List<Reserva>> _getReservas() async {
    final sql = Supabase.instance.client;
    final res = await sql
        .from('reservas')
        .select('id, mesa_id, nombre_cliente, fecha_hora, estado')
        .order('fecha_hora', ascending: false);
    final list = res as List<dynamic>;
    return list.map((e) => Reserva.fromMap(e as Map<String, dynamic>)).toList();
  }

  void fetchReservas() {
    lstReservas = _getReservas();
    notifyListeners();
  }

  Future<void> cancelarReserva(Reserva reserva) async {
    final sql = Supabase.instance.client;
    await sql.from('reservas').delete().eq('id', reserva.id).select();
    await sql
        .from('mesas')
        .update({'estado': 'LIBRE', 'ocupada_desde': null})
        .eq('id', reserva.mesaId)
        .select();
    fetchReservas();
  }
}
