import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class DetallesPedido {
  final String nombre;
  final int cantidad;
  final double precio;

  DetallesPedido({required this.nombre, required this.cantidad, required this.precio});

  factory DetallesPedido.fromMap(Map<String, dynamic> map) {
    final plato = map['plato'] as Map<String, dynamic>;
    return DetallesPedido(
      nombre: plato['nombre'] as String,
      cantidad: map['cantidad'] as int,
      precio: (plato['precio'] as num).toDouble(),
    );
  }
}

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late Future<List<Pedido>> _lstPedidos;

  @override
  void initState() {
    super.initState();
    _lstPedidos = _getPedidos();
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

  Future<List<DetallesPedido>> _getDetalles(int pedidoId) async {
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

  Future<void> _marcarEntregado(int pedidoId) async {
    final sql = Supabase.instance.client;
    await sql.from('pedidos').update({'estado': 'ENTREGADO'}).eq('id', pedidoId).select();
    if (!mounted) return;
    setState(() {
      _lstPedidos = _getPedidos();
    });
  }

  void _popUpDetalles(Pedido pedido) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Pedido #${pedido.id} - Mesa ${pedido.mesaId}'),
          content: FutureBuilder<List<DetallesPedido>>(
            future: _getDetalles(pedido.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snap.hasError) {
                return Text('Error: ${snap.error}');
              }
              final detalles = snap.data!;
              double total = detalles.fold(0, (sum, d) => sum + d.precio * d.cantidad);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...detalles.map(
                    (d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${d.nombre} x${d.cantidad}')),
                          Text('€${(d.precio * d.cantidad).toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '€${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _marcarEntregado(pedido.id);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Entregado'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pedido>>(
      future: _lstPedidos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final pedidos = snapshot.data!;
        if (pedidos.isEmpty) {
          return const Center(child: Text('No hay pedidos.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: pedidos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final pedido = pedidos[index];
            final hora = DateFormat('HH:mm').format(pedido.fecha.toLocal());
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
              child: ListTile(
                title: Text('Pedido #${pedido.id} - Mesa ${pedido.mesaId}'),
                subtitle: Text('Hora: $hora • Estado: ${pedido.estado}'),
                onTap: () => _popUpDetalles(pedido),
              ),
            );
          },
        );
      },
    );
  }
}
