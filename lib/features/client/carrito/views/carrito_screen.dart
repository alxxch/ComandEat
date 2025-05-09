import 'package:comandeat/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/plato.dart';
import '../../../../core/services/providers.dart';
import '../controllers/carrito_controller.dart';

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
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => carritoCtrl.quitarPorCompleto(plato),
                          child: ListTile(
                            leading: plato.fotoUrl != null ? Image.network(plato.fotoUrl!, width: 50, fit: BoxFit.cover) : const Icon(Icons.fastfood),
                            title: Text(plato.nombre),
                            subtitle: Text('${(plato.precio * qty).toStringAsFixed(2)} €'),
                            trailing: Text('x$qty', style: Theme.of(context).textTheme.titleMedium),
                            onTap: () => carritoCtrl.quitarUno(plato),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: Theme.of(context).textTheme.titleMedium),
                        Text('${carritoCtrl.total().toStringAsFixed(2)} €', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send, color: Colors.black),
                      label: const Text('Enviar pedido'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final idPedido = await pedidoRepo.sendPedido(carrito);
                          carritoCtrl.limpiar();
                          if (context.mounted) {
                            context.toEstadoPedido(idPedido);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
