class DetallesPedido {
  final String nombre;
  final int cantidad;
  final double precio;

  DetallesPedido({required this.nombre, required this.cantidad, required this.precio});

  factory DetallesPedido.fromMap(Map<String, dynamic> map) {
    final plato = map['plato'] as Map<String, dynamic>;
    return DetallesPedido(
      nombre: plato['nombre'] as String,
      cantidad: map['cantidad'] as int,
      precio: (plato['precio'] as num).toDouble(),
    );
  }
}
