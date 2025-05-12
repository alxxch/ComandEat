class Mesa {
  final int id;
  final int numero;
  final String estado;
  final DateTime? ocupadaDesde;
  final String? cliente;
  final DateTime? fechaReserva;

  Mesa({
    required this.id,
    required this.numero,
    required this.estado,
    this.ocupadaDesde,
    this.cliente,
    this.fechaReserva,
  });

  factory Mesa.fromMap(Map<String, dynamic> m) {
    final lstReservas = m['reservas'] as List<dynamic>?;
    String? cliente;
    DateTime? fecha;
    if (lstReservas != null && lstReservas.isNotEmpty) {
      final r = lstReservas.first as Map<String, dynamic>;
      cliente = r['nombre_cliente'] as String?;
      fecha = DateTime.parse(r['fecha_hora'] as String);
    }
    final ocupada =
        m['ocupada_desde'] != null ? DateTime.parse(m['ocupada_desde'] as String) : null;
    return Mesa(
      id: m['id'] as int,
      numero: m['numero'] as int,
      estado: m['estado'] as String,
      ocupadaDesde: ocupada,
      cliente: cliente,
      fechaReserva: fecha,
    );
  }
}
