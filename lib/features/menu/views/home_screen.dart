import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../carrito/controllers/carrito_controller.dart';
import '../../carrito/views/carrito_screen.dart';
import '../controllers/menu_controller.dart';
import '../../../core/services/providers.dart';

class Categoria {
  final int id;
  final String nombre;

  const Categoria(this.id, this.nombre);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  final List<Categoria> categorias = const [
    Categoria(1, 'Entrantes'),
    //Categoria(2, 'Platos principales'),
    Categoria(2, 'Pizzas'),
    Categoria(3, 'Postres'),
    Categoria(4, 'Bebidas'),
  ];

  late Categoria _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _categoriaSeleccionada = categorias.first;
  }

  @override
  Widget build(BuildContext ctx) {
    final platosFiltrados = ref.watch(menuControllerProvider).whenData((lista) {
      return lista
          .where((p) => p.categoriaId == _categoriaSeleccionada.id)
          .toList();
    });

    return Scaffold(
      // ──────────────── AppBar ────────────────
      appBar: AppBar(
        title: const Text('ComandEat', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // ──────────────── Body ────────────────
      body:
          _selectedTab == 0
              ? Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categorias.length,
                      itemBuilder: (_, i) {
                        final cat = categorias[i];
                        final sel = cat == _categoriaSeleccionada;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text(
                              cat.nombre,
                              style: TextStyle(
                                color: sel ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: sel,
                            selectedColor: Colors.black87,
                            backgroundColor: Colors.grey[200],
                            onSelected:
                                (_) => setState(
                                  () => _categoriaSeleccionada = cat,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: platosFiltrados.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (list) {
                        if (list.isEmpty)
                          return const Center(child: Text('Sin platos'));
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: list.length,
                          itemBuilder: (context, idx) {
                            final p = list[idx];
                            return Dismissible(
                              key: ValueKey(p.id),
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                color: Colors.black87,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                ref
                                    .read(carritoControllerProvider.notifier)
                                    .agregar(p);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${p.nombre} añadido al carrito',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                                return false;
                              },
                              child: ListTile(
                                leading:
                                    p.fotoUrl != null
                                        ? Image.network(
                                          p.fotoUrl!,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        )
                                        : const Icon(
                                          Icons.fastfood,
                                          color: Colors.black,
                                        ),
                                title: Text(p.nombre),
                                subtitle: Text(
                                  '${p.precio.toStringAsFixed(2)} €',
                                ),
                                onTap:
                                    () => ref
                                        .read(
                                          carritoControllerProvider.notifier,
                                        )
                                        .agregar(p),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
              : const CarritoScreen(),

      // ──────────────── BottomNav ────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
