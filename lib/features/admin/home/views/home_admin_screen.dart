import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/mesa.dart';
import '../controllers/home_admin_controller.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({Key? key}) : super(key: key);

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  late final HomeAdminController ctr;

  @override
  void initState() {
    super.initState();
    ctr = HomeAdminController();
    ctr.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _showMesaDialog(Mesa mesa) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Mesa ${mesa.numero}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estado: ${mesa.estado.toUpperCase()}'),
              if (mesa.fechaReserva != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reservada: ${DateFormat('HH:mm').format(mesa.fechaReserva!.toLocal())}',
                ),
              ],
              if (mesa.estado == 'RESERVADA' && mesa.cliente != null) ...[
                const SizedBox(height: 8),
                Text('Cliente: ${mesa.cliente!}'),
              ],
              if (mesa.estado == 'OCUPADA' && mesa.ocupadaDesde != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Ocupada desde: ${DateFormat('HH:mm').format(mesa.ocupadaDesde!.toLocal())}',
                ),
              ],
            ],
          ),
          actions: [
            if (mesa.estado == 'LIBRE') ...[
              TextButton(
                onPressed: () async {
                  await ctr.reservarMesa(mesa);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Reservar'),
              ),
              TextButton(
                onPressed: () async {
                  await ctr.ocuparMesa(mesa);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Ocupar'),
              ),
            ],
            if (mesa.estado == 'RESERVADA') ...[
              TextButton(
                onPressed: () async {
                  await ctr.confirmarLlegada(mesa);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Confirmar llegada'),
              ),
              TextButton(
                onPressed: () async {
                  await ctr.cancelarReserva(mesa);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancelar Reserva'),
              ),
            ],
            if (mesa.estado == 'OCUPADA')
              TextButton(
                onPressed: () async {
                  await ctr.liberarMesa(mesa.id);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Liberar'),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _btnSelector(
                lblTexto: DateFormat('dd/MM/yyyy').format(ctr.selectedDate),
                anterior: ctr.prevDate,
                siguiente: ctr.nextDate,
              ),
              const SizedBox(width: 12),
              _btnSelector(
                lblTexto: ctr.salas[ctr.salaIndex],
                anterior: ctr.prevSala,
                siguiente: ctr.nextSala,
              ),
              const SizedBox(width: 12),
              _btnSelector(
                lblTexto: ctr.horas[ctr.horasIndex],
                anterior: ctr.prevFranja,
                siguiente: ctr.nextFranja,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<Mesa>>(
            future: ctr.lstMesas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final mesas = snapshot.data!;
              return GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                padding: const EdgeInsets.all(24),
                children:
                    mesas.map((mesa) {
                      Color bg;
                      switch (mesa.estado) {
                        case 'OCUPADA':
                          bg = Colors.red.shade200;
                          break;
                        case 'RESERVADA':
                          bg = Colors.brown.shade200;
                          break;
                        default:
                          bg = Colors.green.shade200;
                      }
                      return GestureDetector(
                        onTap: () => _showMesaDialog(mesa),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Mesa ${mesa.numero}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              widgetLegenda(color: Color(0xFFA5D6A7), lblColor: 'Libre'),
              SizedBox(width: 16),
              widgetLegenda(color: Color(0xFFBCAAA4), lblColor: 'Reservada'),
              SizedBox(width: 16),
              widgetLegenda(color: Color(0xFFEF9A9A), lblColor: 'Ocupada'),
            ],
          ),
        ),
      ],
    );
  }
}

class _btnSelector extends StatelessWidget {
  final String lblTexto;
  final VoidCallback anterior;
  final VoidCallback siguiente;

  const _btnSelector({
    required this.lblTexto,
    required this.anterior,
    required this.siguiente,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: anterior),
        Text(lblTexto),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: siguiente),
      ],
    ),
  );
}

class widgetLegenda extends StatelessWidget {
  final Color color;
  final String lblColor;

  const widgetLegenda({Key? key, required this.color, required this.lblColor})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Text(lblColor),
      ],
    );
  }
}
