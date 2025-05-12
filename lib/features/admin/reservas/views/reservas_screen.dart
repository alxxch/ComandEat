import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/reserva.dart';
import '../controllers/reservas.controller.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({Key? key}) : super(key: key);

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  late final ReservasController ctr;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    ctr = ReservasController();
    _listener = () {
      if (mounted) setState(() {});
    };
    ctr.addListener(_listener);
  }

  @override
  void dispose() {
    ctr.removeListener(_listener);
    ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reserva>>(
      future: ctr.lstReservas,
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
                            await ctr.cancelarReserva(reserva);
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
