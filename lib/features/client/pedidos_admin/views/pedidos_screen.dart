import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/pedido.dart';
import '../controllers/pedidos_controller.dart';

class PedidosScreen extends ConsumerWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidos = ref.watch(pedidosAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos en curso')),
      body: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (_, i) {
          final pedido = pedidos[i];
          return ListTile(
            title: Text('Mesa ${pedido.mesaId}'),
            subtitle: Text('Estado: ${pedido.estado.name.toUpperCase()}'),
            trailing: PopupMenuButton<EstadoPedido>(
              onSelected: (nuevoEstado) {
                ref
                    .read(pedidosAdminProvider.notifier)
                    .actualizarEstado(pedido.id, nuevoEstado);
              },
              itemBuilder:
                  (_) =>
                      EstadoPedido.values
                          .map(
                            (e) => PopupMenuItem(
                              value: e,
                              child: Text(e.name.toUpperCase()),
                            ),
                          )
                          .toList(),
            ),
          );
        },
      ),
    );
  }
}
