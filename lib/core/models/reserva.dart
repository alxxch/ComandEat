import 'package:intl/intl.dart';

class Reserva {
  final int id;
  final int mesaId;
  final String nombreCliente;
  final DateTime fechaHora;
  final String estado;

  Reserva({
    required this.id,
    required this.mesaId,
    required this.nombreCliente,
    required this.fechaHora,
    required this.estado,
  });

  factory Reserva.fromMap(Map<String, dynamic> m) {
    return Reserva(
      id: m['id'] as int,
      mesaId: m['mesa_id'] as int,
      nombreCliente: m['nombre_cliente'] as String,
      fechaHora: DateTime.parse(m['fecha_hora'] as String),
      estado: m['estado'] as String,
    );
  }

  String get fechaFormatted => DateFormat('dd/MM/yyyy').format(fechaHora.toLocal());

  String get horaFormatted => DateFormat('HH:mm').format(fechaHora.toLocal());

  bool get isCancelada => estado.toLowerCase() == 'cancelada';
}
