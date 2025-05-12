import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/pedido_detalle.dart';

class Pedido {
  final int id;
  final int mesaId;
  final DateTime fecha;
  final String estado;

  Pedido({
    required this.id,
    required this.mesaId,
    required this.fecha,
    required this.estado,
  });

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'] as int,
      mesaId: map['mesa_id'] as int,
      fecha: DateTime.parse(map['fecha_hora'] as String),
      estado: map['estado'] as String,
    );
  }
}

class PedidosController extends ChangeNotifier {
  Future<List<Pedido>> lstPedidos = Future.value([]);

  PedidosController() {
    fetchPedidos();
  }

  Future<List<Pedido>> _getPedidos() async {
    final sql = Supabase.instance.client;
    final pedidos = await sql
        .from('pedidos')
        .select('id, mesa_id, fecha_hora, estado')
        .order('fecha_hora', ascending: false);
    final pedidosDevolver = pedidos as List<dynamic>;
    return pedidosDevolver.map((e) => Pedido.fromMap(e as Map<String, dynamic>)).toList();
  }

  void fetchPedidos() {
    lstPedidos = _getPedidos();
    notifyListeners();
  }

  Future<List<DetallesPedido>> getDetalles(int pedidoId) async {
    final sql = Supabase.instance.client;
    final detalles = await sql
        .from('pedido_detalle')
        .select('cantidad, plato:platos(nombre, precio)')
        .eq('pedido_id', pedidoId);
    final detallesDevolver = detalles as List<dynamic>;
    return detallesDevolver
        .map((e) => DetallesPedido.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> marcarEntregado(int pedidoId) async {
    final sql = Supabase.instance.client;
    await sql.from('pedidos').update({'estado': 'ENTREGADO'}).eq('id', pedidoId).select();
    fetchPedidos();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
