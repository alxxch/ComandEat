import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/notificacion.dart';
import '../controllers/notificaciones_controller.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late final NotificacionesController ctr;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    ctr = NotificacionesController();
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                final eliminar = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Eliminar todas las notificaciones'),
                        content: const Text(
                          '¿Estás seguro de que desea eliminar todas las notificaciones?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                );
                if (eliminar == true) {
                  await ctr.eliminarTodas();
                }
              },
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar todas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade200,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Notificacion>>(
            future: ctr.lstNotis,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final notis = snapshot.data!;
              if (notis.isEmpty) {
                return const Center(child: Text('No hay notificaciones.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notis.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final noti = notis[index];
                  final fecha = DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(noti.fechaHora.toLocal());
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                    child: ListTile(
                      title: Text('${noti.tipo.toUpperCase()} - Mesa ${noti.mesaId}'),
                      subtitle: Text(fecha),
                      trailing: TextButton(
                        onPressed:
                            noti.atendida
                                ? null
                                : () async => await ctr.marcarAtendida(noti),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              noti.atendida ? Colors.grey.shade300 : Colors.blue.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          noti.atendida ? 'Atendida' : 'Marcar atendida',
                          style: TextStyle(
                            color: noti.atendida ? Colors.grey : Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
