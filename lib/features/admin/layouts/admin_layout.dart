import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/providers.dart';

class AdminLayout extends ConsumerWidget {
  final Widget screenActual;
  final String rutaActual;

  const AdminLayout({Key? key, required this.screenActual, required this.rutaActual})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notisCount = ref.watch(notificacionesCountProvider);
    final navItems = [
      _NavItem(lblNombre: 'Home', icon: Icons.home, ruta: 'home'),
      _NavItem(lblNombre: 'Pedidos', icon: Icons.receipt_long, ruta: 'pedidos'),
      _NavItem(lblNombre: 'Reservas', icon: Icons.calendar_today, ruta: 'reservas'),
      _NavItem(lblNombre: 'Gestión', icon: Icons.settings, ruta: 'gestion'),
    ];

    return Scaffold(
      body: Row(
        children: [
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
                      Text(
                        'ComandEat',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children:
                        navItems.map((item) {
                          final isSelected = rutaActual.startsWith('/admin/${item.ruta}');
                          return ListTile(
                            leading: Icon(
                              item.icon,
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.black54,
                            ),
                            title: Text(
                              item.lblNombre,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.black87,
                              ),
                            ),
                            selected: isSelected,
                            onTap: () => context.goNamed(item.ruta),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: const [Icon(Icons.fastfood, color: Colors.black87)]),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            tooltip: 'Información',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Información de la App'),
                                    content: const Text(
                                      'Desarrollado por Alejandro Posadas Martín, esta aplicación dispone de licencia para uso educativo.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(dialogContext).pop(),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () => context.goNamed('notificaciones'),
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
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  child: Text(
                                    notisCount
                                        .toString()
                                        .split(" ")
                                        .last
                                        .replaceAll(")", ""),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
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
                Expanded(
                  child: Padding(padding: const EdgeInsets.all(24), child: screenActual),
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
  final String lblNombre;
  final IconData icon;
  final String ruta;

  const _NavItem({required this.lblNombre, required this.icon, required this.ruta});
}
