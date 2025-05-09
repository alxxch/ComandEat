import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late Future<List<Notificacion>> _lstNotis;

  @override
  void initState() {
    super.initState();
    _lstNotis = _getNotificaciones();
  }

  Future<List<Notificacion>> _getNotificaciones() async {
    final sql = Supabase.instance.client;
    final notis = await sql
        .from('notificaciones')
        .select('id, mesa_id, tipo, fecha_hora, atendida')
        .order('fecha_hora', ascending: false);
    final notisDevolver = notis as List<dynamic>;
    return notisDevolver
        .map((e) => Notificacion.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _marcarAtendida(Notificacion noti) async {
    final sql = Supabase.instance.client;
    await sql
        .from('notificaciones')
        .update({'atendida': true})
        .eq('id', noti.id)
        .select();
    if (!mounted) return;
    setState(() {
      _lstNotis = _getNotificaciones();
    });
  }

  Future<void> _eliminarTodas() async {
    final sql = Supabase.instance.client;
    await sql.from('notificaciones').delete().eq('tipo', 'llamada').select();
    if (!mounted) return;
    setState(() {
      _lstNotis = _getNotificaciones();
    });
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
                  await _eliminarTodas();
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
            future: _lstNotis,
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
                                : () async => await _marcarAtendida(noti),
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
