import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../carrito/controllers/carrito_controller.dart';
import '../controllers/menu_controller.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platosAsync = ref.watch(menuControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Menú'), actions: [IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => context.push('/carrito'))]),
      body: platosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data:
            (platos) => ListView.builder(
              itemCount: platos.length,
              itemBuilder: (_, i) {
                final p = platos[i];
                return Dismissible(
                  key: ValueKey(p.id),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Theme.of(context).colorScheme.primary,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.add_shopping_cart, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    ref.read(carritoControllerProvider.notifier).agregar(p);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.nombre} añadido al carrito')));

                    return false;
                  },

                  child: ListTile(
                    leading: p.fotoUrl != null ? Image.network(p.fotoUrl!, width: 50, fit: BoxFit.cover) : const Icon(Icons.fastfood),
                    title: Text(p.nombre),
                    subtitle: Text('${p.precio.toStringAsFixed(2)} €'),
                    onTap: () => ref.read(carritoControllerProvider.notifier).agregar(p),
                  ),
                );
              },
            ),
      ),
    );
  }
}
