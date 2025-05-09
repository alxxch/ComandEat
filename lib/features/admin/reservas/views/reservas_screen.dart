import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de Reserva
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

/// Pantalla de Reservas para el administrador
class ReservasScreen extends StatefulWidget {
  const ReservasScreen({Key? key}) : super(key: key);

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  late Future<List<Reserva>> _reservasFuture;

  @override
  void initState() {
    super.initState();
    _reservasFuture = _fetchReservas();
  }

  /// Obtiene las reservas desde Supabase, ordenadas por fecha desc
  Future<List<Reserva>> _fetchReservas() async {
    final supa = Supabase.instance.client;
    final raw = await supa
        .from('reservas')
        .select('id, mesa_id, nombre_cliente, fecha_hora, estado')
        .order('fecha_hora', ascending: false);
    final data = raw as List<dynamic>;
    return data.map((e) => Reserva.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// Cancela la reserva y libera la mesa
  Future<void> _cancelarReserva(Reserva reserva) async {
    final supa = Supabase.instance.client;
    // 1) Actualizar estado de reserva
    await supa
        .from('reservas')
        .delete()
        .eq('id', reserva.id)
        .select();
    // 2) Liberar mesa asociada
    await supa
        .from('mesas')
        .update({'estado': 'LIBRE', 'ocupada_desde': null})
        .eq('id', reserva.mesaId)
        .select();
    // 3) Refrescar lista
    setState(() {
      _reservasFuture = _fetchReservas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reserva>>(
      future: _reservasFuture,
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
            final r = reservas[index];
            final fecha = DateFormat(
              'dd/MM/yyyy',
            ).format(r.fechaHora.toLocal());
            final hora = DateFormat('HH:mm').format(r.fechaHora.toLocal());
            final isCancelada = r.estado.toLowerCase() == 'CANCELADA';
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Text(
                    r.mesaId.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('Reserva #${r.id} - Mesa ${r.mesaId}'),
                subtitle: Text('Cliente: ${r.nombreCliente} • $fecha • $hora'),
                trailing: TextButton(
                  onPressed:
                      isCancelada
                          ? null
                          : () async {
                            await _cancelarReserva(r);
                          },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isCancelada
                            ? Colors.grey.shade300
                            : Colors.red.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
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
