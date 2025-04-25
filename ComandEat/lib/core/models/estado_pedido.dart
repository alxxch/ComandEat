enum EstadoPedido {
  pendiente,
  preparacion,
  listo,
  entregado;

  static EstadoPedido fromString(String s) {
    switch (s.toUpperCase()) {
      case 'PREPARACION':
        return EstadoPedido.preparacion;
      case 'LISTO':
        return EstadoPedido.listo;
      case 'ENTREGADO':
        return EstadoPedido.entregado;
      default:
        return EstadoPedido.pendiente;
    }
  }

  String get label => switch (this) {
    EstadoPedido.pendiente    => 'Pendiente',
    EstadoPedido.preparacion => 'En preparación',
    EstadoPedido.listo       => 'Listo',
    EstadoPedido.entregado   => 'Entregado',
  };
}
