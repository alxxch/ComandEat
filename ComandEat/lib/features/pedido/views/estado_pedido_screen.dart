import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/pedido_controller.dart';

class EstadoPedidoScreen extends ConsumerWidget {
  const EstadoPedidoScreen({super.key, required this.pedidoId});
  final int pedidoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoAsync = ref.watch(pedidoControllerProvider(pedidoId));

    return Scaffold(
      appBar: AppBar(title: Text('Pedido #$pedidoId')),
      body: estadoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (estado) => Center(
          child: Text(
            estado.label,
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
      ),
    );
  }
}
