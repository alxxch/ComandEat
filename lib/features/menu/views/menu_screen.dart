import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/allergen_icons.dart';
import '../../../core/services/providers.dart' hide menuControllerProvider; // mesaIdProvider, notificationRepoProvider
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

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  String _searchQuery = '';

  // Lista estática de categorías
  final List<Categoria> categorias = const [Categoria(1, 'Entrantes'), Categoria(2, 'Pizzas'), Categoria(3, 'Postres'), Categoria(4, 'Bebidas')];

  late Categoria _categoriaSeleccionada;
  late final AnimationController _animCtrl;
  late final CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _categoriaSeleccionada = categorias.first;

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _curve = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _runAddToCartAnimation(GlobalKey imageKey) async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final renderBox = imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final startOffset = renderBox.localToGlobal(Offset.zero);
    final startSize = renderBox.size;

    final screenSize = MediaQuery.of(context).size;
    final endOffset = Offset(screenSize.width - 40, screenSize.height - 80);

    final imageWidget = imageKey.currentWidget;
    String? imageUrl;
    if (imageWidget is Image && imageWidget.image is NetworkImage) {
      imageUrl = (imageWidget.image as NetworkImage).url;
    }
    if (imageUrl == null) return;

    final entry = OverlayEntry(
      builder: (ctx) {
        return AnimatedBuilder(
          animation: _curve,
          builder: (ctx, child) {
            final dx = lerpDouble(startOffset.dx, endOffset.dx, _curve.value)!;
            final dy = lerpDouble(startOffset.dy, endOffset.dy, _curve.value)!;
            final size = lerpDouble(startSize.width, 24, _curve.value)!;
            return Positioned(left: dx, top: dy, child: SizedBox(width: size, height: size, child: child));
          },
          child: Image.network(imageUrl!, fit: BoxFit.cover),
        );
      },
    );

    overlay.insert(entry);
    await _animCtrl.forward();
    entry.remove();
    _animCtrl.reset();
  }

  Future<void> _onCallWaiter() async {
    final mesaId = ref.read(mesaIdProvider);
    try {
      await ref.read(notificationRepoProvider).llamarCamarero(mesaId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Camarero llamado!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al llamar: \$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final platosAsync = ref.watch(menuControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ComandEat', style: TextStyle(color: Colors.black)), centerTitle: true, backgroundColor: Colors.white, elevation: 0),
      body:
          _selectedTab == 0
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
                            label: Text(cat.nombre, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                            selected: isSelected,
                            selectedColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.grey[200],
                            onSelected: (_) {
                              setState(() {
                                _categoriaSeleccionada = cat;
                                _searchQuery = '';
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // ─── Barra de búsqueda ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar plato...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ),
                      onChanged: (text) => setState(() => _searchQuery = text),
                    ),
                  ),

                  // ─── Lista de platos ───
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: KeyedSubtree(
                        key: ValueKey('\${_categoriaSeleccionada.id}|\$_searchQuery'),
                        child: platosAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: \$e')),
                          data: (platos) {
                            final list =
                                platos.where((p) {
                                  final matchCat = p.categoriaId == _categoriaSeleccionada.id;
                                  final matchSearch = _searchQuery.isEmpty || p.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
                                  return matchCat && matchSearch;
                                }).toList();

                            if (list.isEmpty) {
                              return const Center(child: Text('Sin platos'));
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: list.length,
                              itemBuilder: (context, idx) {
                                final p = list[idx];
                                final imageKey = GlobalKey();
                                return Dismissible(
                                  key: ValueKey(p.id),
                                  direction: DismissDirection.startToEnd,
                                  background: Container(
                                    color: Colors.black87,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: const Icon(Icons.add_shopping_cart, color: Colors.white),
                                  ),
                                  confirmDismiss: (_) async {
                                    await _runAddToCartAnimation(imageKey);
                                    ref.read(carritoControllerProvider.notifier).agregar(p);
                                    return false;
                                  },

                                  // Tarjeta centrada con ancho máximo y margen
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 500, // ancho máximo
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child:
                                                p.fotoUrl != null
                                                    ? Image.network(p.fotoUrl!, key: imageKey, width: 50, height: 50, fit: BoxFit.cover)
                                                    : const Icon(Icons.fastfood, color: Colors.black),
                                          ),
                                          title: Text(p.nombre),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('\${p.precio.toStringAsFixed(2)} €'),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                children:
                                                    p.allergenTags.map((tag) {
                                                      final icon = allergenIconMap[tag] ?? Icons.error;
                                                      return Tooltip(message: tag, child: Icon(icon, size: 16, color: Colors.redAccent));
                                                    }).toList(),
                                              ),
                                            ],
                                          ),
                                          onTap: () async {
                                            await _runAddToCartAnimation(imageKey);
                                            ref.read(carritoControllerProvider.notifier).agregar(p);
                                          },
                                        ),
                                      ),
                                    ),
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

      // Botón circular “Llamar camarero”
      floatingActionButton: FloatingActionButton(onPressed: _onCallWaiter, backgroundColor: Colors.white, child: const Icon(Icons.notifications, color: Colors.black)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined, color: Colors.black54), activeIcon: Icon(Icons.home, color: Colors.black), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.black54),
            activeIcon: Icon(Icons.shopping_cart, color: Colors.black),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
