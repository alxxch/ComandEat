import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/layouts/admin_layout.dart';
import '../features/client/menu/views/scan_qr_screen.dart';
import '../features/client/menu/views/home_screen.dart';
import '../features/client/splash/views/splash_screen.dart';
import '../features/admin/login/views/login_screen.dart';
import '../features/admin/home/views/home_admin_screen.dart';
import '../features/admin/pedidos/views/pedidos_screen.dart';
import '../features/admin/reservas/views/reservas_screen.dart';
import '../features/admin/gestion/views/gestion_screen.dart';
import '../features/admin/perfil/views/profile_screen.dart';

part 'route_names.dart';

final GoRouter clientRoutes = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),
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

final GoRouter adminRoutes = GoRouter(
  initialLocation: '/login',
  routes: [
    // Login
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Shell for all admin routes: persistent AppBar + Sidebar
    ShellRoute(
      builder: (context, state, child) {
        return AdminLayout(
          child: child,
          currentLocation: state.location,
        );
      },
      routes: [
        GoRoute(
          path: '/admin/home',
          name: 'home',
          builder: (context, state) => const HomeAdminScreen(),
        ),
        GoRoute(
          path: '/admin/pedidos',
          name: 'pedidos',
          builder: (context, state) => const PedidosScreen(),
        ),
        GoRoute(
          path: '/admin/reservas',
          name: 'reservas',
          builder: (context, state) => const ReservasScreen(),
        ),
        GoRoute(
          path: '/admin/gestion',
          name: 'gestion',
          builder: (context, state) => const GestionScreen(),
        ),
        GoRoute(
          path: '/admin/perfil',
          name: 'perfil',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Ruta no encontrada: ${state.location}')),
  ),
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
