import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de Pedido
class Pedido {
  final int id;
  final int mesaId;
  final DateTime fecha;
  final String estado;

  Pedido({required this.id, required this.mesaId, required this.fecha, required this.estado});

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(id: map['id'] as int, mesaId: map['mesa_id'] as int, fecha: DateTime.parse(map['fecha_hora'] as String), estado: map['estado'] as String);
  }
}

/// Modelo de detalle de un pedido
class Detalle {
  final String nombre;
  final int cantidad;
  final double precio;

  Detalle({required this.nombre, required this.cantidad, required this.precio});

  factory Detalle.fromMap(Map<String, dynamic> map) {
    final plato = map['plato'] as Map<String, dynamic>;
    return Detalle(nombre: plato['nombre'] as String, cantidad: map['cantidad'] as int, precio: (plato['precio'] as num).toDouble());
  }
}

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _fetchPedidos();
  }

  Future<List<Pedido>> _fetchPedidos() async {
    final supa = Supabase.instance.client;
    final raw = await supa.from('pedidos').select('id, mesa_id, fecha_hora, estado').order('fecha_hora', ascending: false);
    final data = raw as List<dynamic>;
    return data.map((e) => Pedido.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<Detalle>> _fetchDetalles(int pedidoId) async {
    final supa = Supabase.instance.client;
    final raw = await supa.from('pedido_detalle').select('cantidad, plato:platos(nombre, precio)').eq('pedido_id', pedidoId);
    final data = raw as List<dynamic>;
    return data.map((e) => Detalle.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> _marcarEntregado(int pedidoId) async {
    final supa = Supabase.instance.client;
    await supa.from('pedidos').update({'estado': 'Entregado'}).eq('id', pedidoId).select();
    setState(() => _pedidosFuture = _fetchPedidos());
  }

  void _showDetalleDialog(Pedido pedido) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Pedido #${pedido.id} - Mesa ${pedido.mesaId}'),
          content: FutureBuilder<List<Detalle>>(
            future: _fetchDetalles(pedido.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
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
                        children: [Expanded(child: Text('${d.nombre} x${d.cantidad}')), Text('€${(d.precio * d.cantidad).toStringAsFixed(2)}')],
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('€${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cerrar')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pedido>>(
      future: _pedidosFuture,
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
                onTap: () => _showDetalleDialog(pedido),
              ),
            );
          },
        );
      },
    );
  }
}
