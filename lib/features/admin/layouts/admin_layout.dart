import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Layout principal para la app Admin en pantallas grandes.
/// Barra Superior + Sidebar izquierdo + área de contenido.
class AdminLayout extends StatelessWidget {
  /// Child es la pantalla actual.
  final Widget child;
  /// Ruta actual, pasada desde el ShellRoute
  final String currentLocation;

  const AdminLayout({
    Key? key,
    required this.child,
    required this.currentLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define items de navegación
    final navItems = [
      _NavItem(label: 'Home', icon: Icons.home, routeName: 'home'),
      _NavItem(label: 'Pedidos', icon: Icons.receipt_long, routeName: 'pedidos'),
      _NavItem(label: 'Reservas', icon: Icons.calendar_today, routeName: 'reservas'),
      _NavItem(label: 'Gestión', icon: Icons.settings, routeName: 'gestion'),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar de navegación (30% ancho aprox.)
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            color: Colors.grey.shade100,
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Logo + App name
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('ComandEat',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          )),
                    ],
                  ),
                ),
                const Divider(),
                // Items de navegación
                Expanded(
                  child: ListView(
                    children: navItems.map((item) {
                      final isSelected = currentLocation.startsWith('/admin/${item.routeName}');
                      return ListTile(
                        leading: Icon(item.icon,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black54),
                        title: Text(item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black87,
                            )),
                        selected: isSelected,
                        onTap: () => context.goNamed(item.routeName),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // División vertical mínima
          const VerticalDivider(width: 1),

          // Área de contenido (70% ancho aprox.)
          Expanded(
            child: Column(
              children: [
                // Barra Superior
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Izquierda: Logo + nombre
                      Row(
                        children: const [
                          Icon(Icons.fastfood, color: Colors.black87),
                        ],
                      ),

                      // Centro (info, notificaciones)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: null,
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () => context.goNamed('pedidos'),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: const Text(
                                    '11',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 16),
                          // Avatar restaurante
                          InkWell(
                            onTap: () => context.goNamed('perfil'),
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.orangeAccent,
                                ),
                                const SizedBox(width: 8),
                                const Text('Mesón Paco'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contenido dinámico
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String routeName;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.routeName,
  });
}