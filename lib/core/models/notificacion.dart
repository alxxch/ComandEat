class Notificacion {
  final int id;
  final int mesaId;
  final String tipo;
  final DateTime fechaHora;
  final bool atendida;

  Notificacion({
    required this.id,
    required this.mesaId,
    required this.tipo,
    required this.fechaHora,
    required this.atendida,
  });

  factory Notificacion.fromMap(Map<String, dynamic> m) {
    return Notificacion(
      id: m['id'] as int,
      mesaId: m['mesa_id'] as int,
      tipo: m['tipo'] as String,
      fechaHora: DateTime.parse(m['fecha_hora'] as String),
      atendida: m['atendida'] as bool,
    );
  }
}
