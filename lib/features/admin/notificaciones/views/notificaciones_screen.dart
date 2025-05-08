// lib/features/admin/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de Notificación
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

/// Pantalla de Notificaciones para el administrador
class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();

}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late Future<List<Notificacion>> _notisFuture;

  @override
  void initState() {
    super.initState();
    _notisFuture = _fetchNotificaciones();
  }

  Future<List<Notificacion>> _fetchNotificaciones() async {
    final supa = Supabase.instance.client;
    final raw = await supa
        .from('notificaciones')
        .select('id, mesa_id, tipo, fecha_hora, atendida')
        .order('fecha_hora', ascending: false);
    final data = raw as List<dynamic>;
    return data
        .map((e) => Notificacion.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _marcarAtendida(Notificacion n) async {
    final supa = Supabase.instance.client;
    await supa
        .from('notificaciones')
        .update({'atendida': true})
        .eq('id', n.id)
        .select();
    setState(() => _notisFuture = _fetchNotificaciones());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Notificacion>>(
      future: _notisFuture,
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
            final n = notis[index];
            final fecha = DateFormat('dd/MM/yyyy HH:mm').format(n.fechaHora.toLocal());
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
              child: ListTile(
                title: Text('${n.tipo.toUpperCase()} - Mesa ${n.mesaId}'),
                subtitle: Text(fecha),
                trailing: TextButton(
                  onPressed: n.atendida
                      ? null
                      : () async => await _marcarAtendida(n),
                  style: TextButton.styleFrom(
                    backgroundColor: n.atendida ? Colors.grey.shade300 : Colors.blue.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    n.atendida ? 'Atendida' : 'Marcar atendida',
                    style: TextStyle(
                      color: n.atendida ? Colors.grey : Colors.blue.shade800,
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
