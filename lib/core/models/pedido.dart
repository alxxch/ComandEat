enum EstadoPedido { pendiente, preparacion, listo, entregado }

class Pedido {
  final int id;
  final int mesaId;
  final EstadoPedido estado;

  Pedido({required this.id, required this.mesaId, required this.estado});

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
    id: json['id'] as int,
    mesaId: json['mesa_id'] as int,
    estado: EstadoPedido.values.firstWhere(
      (e) => e.name == (json['estado'] as String).toLowerCase(),
    ),
  );
}
