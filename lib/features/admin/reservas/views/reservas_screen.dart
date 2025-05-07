import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pantalla de Reservas para el administrador
class ReservasScreen extends StatefulWidget {
  const ReservasScreen({Key? key}) : super(key: key);

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  // Datos dummy de reservas
  final List<Map<String, dynamic>> reservasDummy = List.generate(
    8,
        (i) => {
      'id': i + 1,
      'mesa': (i % 15) + 1,
      'sala': 'Sala ${(i % 3) + 1}',
      'fecha': DateTime.now().add(Duration(days: i % 5)),
      'hora': '19:00',
      'estado': i % 2 == 0 ? 'Confirmada' : 'Pendiente',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Reservas',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),

        // Lista de reservas
        Expanded(
          child: ListView.separated(
            itemCount: reservasDummy.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final reserva = reservasDummy[index];
              final fechaStr = DateFormat('dd/MM/yyyy').format(reserva['fecha']);
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Text(
                      reserva['mesa'].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('Reserva #${reserva['id']} - Mesa ${reserva['mesa']}'),
                  subtitle: Text('Sala: ${reserva['sala']} • $fechaStr • Hora: ${reserva['hora']}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // TODO: Acción para confirmar llegada o cancelar
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(reserva['estado'] == 'Confirmada' ? 'Cancelar' : 'Confirmar'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
