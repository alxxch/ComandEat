import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/allergen_icons.dart';
import '../controllers/menu_controller.dart';
import '../../carrito/views/carrito_screen.dart';
import '../../../features/carrito/controllers/carrito_controller.dart';

class Categoria {
  final int id;
  final String nombre;
  const Categoria(this.id, this.nombre);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  final List<Categoria> categorias = const [
    Categoria(1, 'Entrantes'),
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
  Widget build(BuildContext context) {
    final platosAsync = ref.watch(menuControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ComandEat', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _selectedTab == 0
          ? Column(
        children: [
          // ─── Selector de categorías ───
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categorias.length,
              itemBuilder: (context, i) {
                final cat = categorias[i];
                final isSelected = cat.id == _categoriaSeleccionada.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(
                      cat.nombre,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.black87,
                    backgroundColor: Colors.grey[200],
                    onSelected: (_) {
                      setState(() => _categoriaSeleccionada = cat);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // ─── Lista de platos filtrados con fade al cambiar de categoría ───
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: KeyedSubtree(
                key: ValueKey<int>(_categoriaSeleccionada.id),
                child: platosAsync.when(
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (platos) {
                    final list = platos
                        .where((p) =>
                    p.categoriaId == _categoriaSeleccionada.id)
                        .toList();
                    if (list.isEmpty) {
                      return const Center(
                          child: Text('Sin platos en esta categoría'));
                    }
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
                                horizontal: 20),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            ref
                                .read(carritoControllerProvider
                                .notifier)
                                .agregar(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${p.nombre} añadido al carrito'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                            return false;
                          },
                          child: ListTile(
                            leading: p.fotoUrl != null
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
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${p.precio.toStringAsFixed(2)} €'),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: p.allergenTags.map((tag) {
                                    final icon =
                                        allergenIconMap[tag] ??
                                            Icons.error;
                                    return Tooltip(
                                      message: tag,
                                      child: Icon(icon,
                                          size: 16,
                                          color: Colors.redAccent),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            onTap: () => ref
                                .read(carritoControllerProvider
                                .notifier)
                                .agregar(p),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      )
          : const CarritoScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.black),
            activeIcon: Icon(Icons.home, color: Colors.black),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
            activeIcon: Icon(Icons.shopping_cart, color: Colors.black),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
