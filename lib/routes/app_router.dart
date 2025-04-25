import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/menu/views/menu_screen.dart';
import '../features/carrito/views/carrito_screen.dart';
import '../features/pedido/views/estado_pedido_screen.dart';

part 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.menu,
  routes: [
    GoRoute(path: Routes.menu, name: RouteNames.menu, builder: (_, __) => const MenuScreen()),
    GoRoute(path: Routes.carrito, name: RouteNames.carrito, builder: (_, __) => const CarritoScreen()),
    GoRoute(
      path: '${Routes.estadoPedido}/:id',
      name: RouteNames.estadoPedido,
      builder: (_, state) {
        final id = state.pathParameters['id']!;
        return EstadoPedidoScreen(pedidoId: int.parse(id));
      },
    ),
  ],
  errorBuilder: (_, __) => const _PageNotFound(),
);

extension RouterX on BuildContext {
  void toCarrito() => pushNamed(RouteNames.carrito);

  void toEstadoPedido(int id) => pushNamed(RouteNames.estadoPedido, pathParameters: {'id': '$id'});
}

class _PageNotFound extends StatelessWidget {
  const _PageNotFound({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Página no encontrada')));
}
