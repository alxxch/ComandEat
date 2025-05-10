import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/providers.dart';
import '../../../../core/utils/allergen_icons.dart';
import '../../carrito/controllers/carrito_controller.dart';
import '../../carrito/views/carrito_screen.dart';

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

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _categoriaActiva = 0;
  String _filtroBusqueda = '';
  bool _isExpanded = false;
  late FocusNode _focusNode;
  final List<Categoria> categorias = const [
    Categoria(1, 'Entrantes'),
    Categoria(2, 'Pizzas'),
    Categoria(3, 'Postres'),
    Categoria(4, 'Bebidas'),
  ];
  late Categoria _categoriaSeleccionada;
  late final AnimationController _ctrAnimacion;
  late final CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _categoriaSeleccionada = categorias.first;
    _ctrAnimacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _curve = CurvedAnimation(parent: _ctrAnimacion, curve: Curves.easeInOut);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _ctrAnimacion.dispose();
    super.dispose();
  }

  Future<void> _animacionAddCarrito(GlobalKey imageKey) async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final render = imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (render == null) return;
    final startPos = render.localToGlobal(Offset.zero);
    final tamano = render.size;
    final pantallaTamano = MediaQuery.of(context).size;
    final endPos = Offset(pantallaTamano.width - 40, pantallaTamano.height - 80);
    final imagenWidget = imageKey.currentWidget;
    String? imagenUrl;
    if (imagenWidget is Image && imagenWidget.image is NetworkImage) {
      imagenUrl = (imagenWidget.image as NetworkImage).url;
    }
    if (imagenUrl == null) return;
    final overEntry = OverlayEntry(
      builder: (ctx) {
        return AnimatedBuilder(
          animation: _curve,
          builder: (ctx, child) {
            final posX = lerpDouble(startPos.dx, endPos.dx, _curve.value)!;
            final posY = lerpDouble(startPos.dy, endPos.dy, _curve.value)!;
            final size = lerpDouble(tamano.width, 24, _curve.value)!;
            return Positioned(
              left: posX,
              top: posY,
              child: SizedBox(width: size, height: size, child: child),
            );
          },
          child: Image.network(imagenUrl!, fit: BoxFit.cover),
        );
      },
    );
    overlay.insert(overEntry);
    await _ctrAnimacion.forward();
    overEntry.remove();
    _ctrAnimacion.reset();
  }

  Future<void> _callCamarero() async {
    final mesaId = ref.read(mesaIdProvider);
    if (mesaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debes escanear el QR de la mesa')),
      );
      return;
    }
    try {
      await ref.read(notificationRepoProvider).callCamarero(mesaId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('¡Camarero llamado!')));
      }
    } catch (e, st) {
      debugPrint('Error al llamar: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
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
      body:
          _categoriaActiva == 0
              ? Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categorias.length,
                      itemBuilder: (context, i) {
                        final categoria = categorias[i];
                        final isActiva = categoria.id == _categoriaSeleccionada.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text(
                              categoria.nombre,
                              style: TextStyle(
                                color: isActiva ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: isActiva,
                            selectedColor: Colors.grey[400],
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            showCheckmark: false,
                            side: BorderSide(color: Colors.transparent),
                            onSelected: (_) {
                              setState(() {
                                _categoriaSeleccionada = categoria;
                                _filtroBusqueda = '';
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isExpanded ? MediaQuery.of(context).size.width - 50 : 50,
                      height: 50,
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                    FocusScope.of(context).requestFocus(_focusNode);
                                  });
                                },
                              ),
                            ),
                          ),
                          if (_isExpanded)
                            Expanded(
                              child: TextField(
                                focusNode: _focusNode,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Buscar plato...',
                                  border: InputBorder.none,
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    _filtroBusqueda = text;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: KeyedSubtree(
                        key: ValueKey('${_categoriaSeleccionada.id}|$_filtroBusqueda'),
                        child: platosAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: ${e.toString()}')),
                          data: (platos) {
                            final lstPlatos =
                                platos.where((p) {
                                  final matchCategoria =
                                      p.categoriaId == _categoriaSeleccionada.id;
                                  final matchBusqueda =
                                      _filtroBusqueda.isEmpty ||
                                      p.nombre.toLowerCase().contains(
                                        _filtroBusqueda.toLowerCase(),
                                      );
                                  return matchCategoria && matchBusqueda;
                                }).toList();

                            if (lstPlatos.isEmpty) {
                              return const Center(child: Text('Sin platos'));
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: lstPlatos.length,
                              itemBuilder: (context, idx) {
                                final plato = lstPlatos[idx];
                                final imagenKey = GlobalKey();
                                return Dismissible(
                                  key: ValueKey(plato.id),
                                  direction: DismissDirection.startToEnd,
                                  background: Container(
                                    color: Colors.black87,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: const Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (_) async {
                                    await _animacionAddCarrito(imagenKey);
                                    ref
                                        .read(carritoControllerProvider.notifier)
                                        .addPlato(plato);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '"${plato.nombre}" añadido al carrito',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 700),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child:
                                                plato.fotoUrl != null
                                                    ? Image.network(
                                                      plato.fotoUrl!,
                                                      key: imagenKey,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    )
                                                    : const Icon(
                                                      Icons.fastfood,
                                                      color: Colors.black,
                                                    ),
                                          ),
                                          title: Text(plato.nombre),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${plato.precio.toStringAsFixed(2)} €',
                                              ),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                children:
                                                    plato.allergenTags.map((tag) {
                                                      final icon =
                                                          mapIconos[tag] ?? Icons.error;
                                                      return Tooltip(
                                                        message: tag,
                                                        child: Icon(
                                                          icon,
                                                          size: 16,
                                                          color: Colors.redAccent,
                                                        ),
                                                      );
                                                    }).toList(),
                                              ),
                                            ],
                                          ),
                                          onTap: () async {
                                            await _animacionAddCarrito(imagenKey);
                                            ref
                                                .read(carritoControllerProvider.notifier)
                                                .addPlato(plato);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '"${plato.nombre}" añadido al carrito',
                                                ),
                                              ),
                                            );
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
      floatingActionButton: FloatingActionButton(
        onPressed: _callCamarero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: Colors.white,
        child: const Icon(Icons.notifications, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _categoriaActiva,
        onTap: (i) => setState(() => _categoriaActiva = i),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.black54),
            activeIcon: Icon(Icons.home, color: Colors.black),
            label: 'Inicio',
          ),
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
