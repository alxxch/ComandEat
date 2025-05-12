import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/mesa.dart';

class HomeAdminController extends ChangeNotifier {
  Future<List<Mesa>> lstMesas = Future.value([]);
  DateTime selectedDate = DateTime.now();
  final List<String> salas = ['Sala 1', 'Sala 2', 'Sala 3'];
  int salaIndex = 0;
  final List<String> horas = ['14:00-15:00', '15:00-16:00', '16:00-17:00'];
  int horasIndex = 0;

  HomeAdminController() {
    fetchMesas();
  }

  Future<List<Mesa>> _getMesas() async {
    final sql = Supabase.instance.client;
    try {
      final resultado = await sql
          .from('mesas')
          .select('id,numero,estado,ocupada_desde,reservas(nombre_cliente,fecha_hora)')
          .order('numero', ascending: true);
      final list = resultado as List<dynamic>;
      return list.map((e) => Mesa.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error cargando mesas: $e');
    }
  }

  void fetchMesas() {
    lstMesas = _getMesas();
    notifyListeners();
  }

  void prevDate() {
    selectedDate = selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void nextDate() {
    selectedDate = selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void prevSala() {
    if (salaIndex > 0) salaIndex--;
    notifyListeners();
  }

  void nextSala() {
    if (salaIndex < salas.length - 1) salaIndex++;
    notifyListeners();
  }

  void prevFranja() {
    if (horasIndex > 0) horasIndex--;
    notifyListeners();
  }

  void nextFranja() {
    if (horasIndex < horas.length - 1) horasIndex++;
    notifyListeners();
  }

  Future<void> ocuparMesa(Mesa mesa) async {
    final sql = Supabase.instance.client;
    await sql
        .from('mesas')
        .update({'estado': 'OCUPADA', 'ocupada_desde': DateTime.now().toIso8601String()})
        .eq('id', mesa.id)
        .select();
    fetchMesas();
  }

  Future<void> reservarMesa(Mesa mesa) async {
    final nombres = ['Raúl', 'María', 'José', 'Ana', 'Luis', 'Laura', 'Pedro'];
    final sql = Supabase.instance.client;
    await sql.from('reservas').insert({
      'mesa_id': mesa.id,
      'nombre_cliente': nombres[Random().nextInt(nombres.length)],
      'fecha_hora': DateTime.now().toIso8601String(),
      'estado': 'ACTIVA',
    });
    await sql.from('mesas').update({'estado': 'RESERVADA'}).eq('id', mesa.id).select();
    fetchMesas();
  }

  Future<void> confirmarLlegada(Mesa mesa) async {
    final sql = Supabase.instance.client;
    await sql
        .from('mesas')
        .update({'estado': 'OCUPADA', 'ocupada_desde': DateTime.now().toIso8601String()})
        .eq('id', mesa.id)
        .select();
    await sql.from('reservas').delete().eq('mesa_id', mesa.id).select();
    fetchMesas();
  }

  Future<void> cancelarReserva(Mesa mesa) async {
    final sql = Supabase.instance.client;
    await sql
        .from('mesas')
        .update({'estado': 'LIBRE', 'ocupada_desde': null})
        .eq('id', mesa.id)
        .select();
    await sql.from('reservas').delete().eq('mesa_id', mesa.id).select();
    fetchMesas();
  }

  Future<void> liberarMesa(int mesaId) async {
    final sql = Supabase.instance.client;
    await sql
        .from('mesas')
        .update({'estado': 'LIBRE', 'ocupada_desde': null})
        .eq('id', mesaId)
        .select();
    fetchMesas();
  }
}
