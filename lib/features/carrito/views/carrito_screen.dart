import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/carrito_controller.dart';
import '../../../core/services/providers.dart';
import '../../../core/models/plato.dart';

class CarritoScreen extends ConsumerWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carrito = ref.watch(carritoControllerProvider);
    final carritoCtrl = ref.read(carritoControllerProvider.notifier);
    final pedidoRepo = ref.read(pedidoRepoProvider);

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
                        final Plato plato = carrito.keys.elementAt(index);
                        final int qty = carrito[plato]!;

                        return Dismissible(
                          key: ValueKey(plato.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed:
                              (_) => carritoCtrl.quitarPorCompleto(plato),
                          child: ListTile(
                            leading:
                                plato.fotoUrl != null
                                    ? Image.network(
                                      plato.fotoUrl!,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.fastfood),
                            title: Text(plato.nombre),
                            trailing: Text('x$qty'),
                            onTap: () => carritoCtrl.quitarUno(plato),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${carritoCtrl.total().toStringAsFixed(2)} €',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar pedido'),
                      onPressed: () async {
                        try {
                          final idPedido = await pedidoRepo.enviarPedido(
                            carrito,
                          );
                          carritoCtrl.limpiar();
                          if (context.mounted) {
                            context.push('/estado-pedido/$idPedido');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
