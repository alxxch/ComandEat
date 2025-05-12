import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/pedido_detalle.dart';
import '../controllers/pedidos_controller.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late final PedidosController ctr;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    ctr = PedidosController();
    _listener = () {
      if (mounted) setState(() {});
    };
    ctr.addListener(_listener);
  }

  @override
  void dispose() {
    ctr.removeListener(_listener);
    ctr.dispose();
    super.dispose();
  }

  void _popUpDetalles(Pedido pedido) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Pedido #${pedido.id} - Mesa ${pedido.mesaId}'),
          content: FutureBuilder<List<DetallesPedido>>(
            future: ctr.getDetalles(pedido.id),
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
            if (pedido.estado != 'ENTREGADO') ...[
              TextButton(
                onPressed: () async {
                  await ctr.marcarEntregado(pedido.id);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Entregado'),
              ),
            ],
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
      future: ctr.lstPedidos,
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
