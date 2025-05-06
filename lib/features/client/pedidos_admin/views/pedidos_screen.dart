import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../llamadas/controllers/llamadas_controller.dart';
import '../controllers/pedidos_controller.dart';
import '../../../../core/models/pedido.dart';

class PedidosScreen extends ConsumerWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(llamadasProvider);

    final pedidos = ref.watch(pedidosAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos en curso')),
      body: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (_, i) {
          final p = pedidos[i];
          return ListTile(
            title: Text('Mesa ${p.mesaId}'),
            subtitle: Text('Estado: ${p.estado.name.toUpperCase()}'),
            trailing: PopupMenuButton<EstadoPedido>(
              onSelected: (nuevoEstado) {
                ref.read(pedidosAdminProvider.notifier).actualizarEstado(p.id, nuevoEstado);
              },
              itemBuilder: (_) => EstadoPedido.values.map((e) => PopupMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
            ),
          );
        },
      ),
    );
  }
}
