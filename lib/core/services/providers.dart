import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_repository.dart';
import 'pedido_repository.dart';

final pedidoRepoProvider = Provider<PedidoRepository>((_) => PedidoRepository());

final menuRepoProvider = Provider<MenuRepository>((_) => MenuRepository());