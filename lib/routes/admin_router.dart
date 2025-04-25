import 'package:go_router/go_router.dart';
import '../features/pedidos_admin/views/pedidos_screen.dart';

final GoRouter adminRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const PedidosScreen()),
  ],
);
