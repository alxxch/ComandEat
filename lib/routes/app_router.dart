import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/menu/views/scan_qr_screen.dart';
import '../features/menu/views/home_screen.dart';

part 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/scan',
  routes: [
    GoRoute(
      path: '/scan',
      name: 'scan',
      builder: (_, __) => const ScanQrScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (_, __) => const HomeScreen(),
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
