import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/carrito_controller.dart';
import '../../../core/services/providers.dart';

class CarritoScreen extends ConsumerWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carrito = ref.watch(carritoControllerProvider);
    final carritoCtrl = ref.read(carritoControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body:
          carrito.isEmpty
              ? const Center(child: Text('Carrito vacío'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: carrito.length,
                      itemBuilder: (context, index) {
                        final plato = carrito.keys.elementAt(index);
                        final cantidad = carrito[plato]!;

                        return Dismissible(
                          key: ValueKey(plato.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => carritoCtrl.quitarPorCompleto(plato),
                          child: ListTile(
                            leading: plato.fotoUrl != null ? Image.network(plato.fotoUrl!, width: 50, fit: BoxFit.cover) : const Icon(Icons.fastfood),
                            title: Text(plato.nombre),
                            subtitle: Text('${plato.precio.toStringAsFixed(2)} €  ×  $cantidad'),
                          ),
                        );
                      },
                    ),
                  ),
                  _TotalSection(total: carritoCtrl.total()),
                  _EnviarButton(carrito: carrito),
                ],
              ),
    );
  }
}

/// Widget que enseña el total formateado
class _TotalSection extends StatelessWidget {
  const _TotalSection({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: Theme.of(context).textTheme.titleMedium),
          Text('${total.toStringAsFixed(2)} €', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Botón que envía el pedido a Supabase
class _EnviarButton extends ConsumerWidget {
  const _EnviarButton({required this.carrito});

  final Map carrito;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carritoCtrl = ref.read(carritoControllerProvider.notifier);
    final pedidoRepo = ref.read(pedidoRepoProvider);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.send),
          label: const Text('Enviar pedido'),
          onPressed:
              carrito.isEmpty
                  ? null
                  : () async {
                    final id = await pedidoRepo.enviarPedido(
                      carrito.cast(), // Map<Plato,int>
                      1, // TODO: mesa real
                    );

                    carritoCtrl.limpiar();
                    if (context.mounted) {
                      context.push('/estado-pedido/$id');
                    }
                  },
        ),
      ),
    );
  }
}
