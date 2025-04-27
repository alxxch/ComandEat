import 'package:flutter/material.dart';

enum EstadoPedido { pendiente, preparacion, listo, entregado }

extension EstadoPedidoX on EstadoPedido {
  String get label => switch (this) {
    EstadoPedido.pendiente => 'Pendiente',
    EstadoPedido.preparacion => 'En preparación',
    EstadoPedido.listo => 'Listo',
    EstadoPedido.entregado => 'Entregado',
  };

  IconData get icon => switch (this) {
    EstadoPedido.pendiente => Icons.timer_outlined,
    EstadoPedido.preparacion => Icons.kitchen_outlined,
    EstadoPedido.listo => Icons.room_service_outlined,
    EstadoPedido.entregado => Icons.check_circle_outline,
  };

  int get step => EstadoPedido.values.indexOf(this);

  static EstadoPedido fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PREPARACION':
        return EstadoPedido.preparacion;
      case 'LISTO':
        return EstadoPedido.listo;
      case 'ENTREGADO':
        return EstadoPedido.entregado;
      case 'PENDIENTE':
      default:
        return EstadoPedido.pendiente;
    }
  }
}

extension EstadoPedidoAnim on EstadoPedido {
  String get animationAsset => switch (this) {
    EstadoPedido.pendiente    => 'assets/animations/pending.json',
    EstadoPedido.preparacion => 'assets/animations/cooking.json',
    EstadoPedido.listo       => 'assets/animations/ready.json',
    EstadoPedido.entregado   => 'assets/animations/done.json',
  };
}
