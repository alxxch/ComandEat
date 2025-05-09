import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({Key? key}) : super(key: key);

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  late Future<List<Reserva>> _lstReservas;

  @override
  void initState() {
    super.initState();
    _lstReservas = _getReservas();
  }

  Future<List<Reserva>> _getReservas() async {
    final sql = Supabase.instance.client;
    final reservas = await sql
        .from('reservas')
        .select('id, mesa_id, nombre_cliente, fecha_hora, estado')
        .order('fecha_hora', ascending: false);
    final reservasDevolver = reservas as List<dynamic>;
    return reservasDevolver
        .map((e) => Reserva.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    final sql = Supabase.instance.client;
    await sql.from('reservas').delete().eq('id', reserva.id).select();
    await sql
        .from('mesas')
        .update({'estado': 'LIBRE', 'ocupada_desde': null})
        .eq('id', reserva.mesaId)
        .select();
    setState(() {
      _lstReservas = _getReservas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reserva>>(
      future: _lstReservas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final reservas = snapshot.data!;
        if (reservas.isEmpty) {
          return const Center(child: Text('No hay reservas.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reservas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final reserva = reservas[index];
            final fecha = DateFormat('dd/MM/yyyy').format(reserva.fechaHora.toLocal());
            final hora = DateFormat('HH:mm').format(reserva.fechaHora.toLocal());
            final isCancelada = reserva.estado.toLowerCase() == 'CANCELADA';
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Text(
                    reserva.mesaId.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('Reserva #${reserva.id} - Mesa ${reserva.mesaId}'),
                subtitle: Text('Cliente: ${reserva.nombreCliente} • $fecha • $hora'),
                trailing: TextButton(
                  onPressed:
                      isCancelada
                          ? null
                          : () async {
                            await _cancelarReserva(reserva);
                          },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isCancelada ? Colors.grey.shade300 : Colors.red.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    isCancelada ? 'Cancelada' : 'Cancelar',
                    style: TextStyle(
                      color: isCancelada ? Colors.grey : Colors.red.shade800,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
