import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de Mesa y su reserva más reciente
class Mesa {
  final int id;
  final int numero;
  final String estado; // 'libre', 'ocupada', 'reservada'
  final String? cliente;
  final DateTime? fechaHora;
  final DateTime? ocupadaDesde;

  Mesa({
    required this.id,
    required this.numero,
    required this.estado,
    this.cliente,
    this.fechaHora,
    this.ocupadaDesde,
  });

  factory Mesa.fromMap(Map<String, dynamic> m) {
    // reservas es la relación anidada
    final resList = m['reservas'] as List<dynamic>?;
    String? cliente;
    DateTime? fecha;
    if (resList != null && resList.isNotEmpty) {
      final r = resList.first as Map<String, dynamic>;
      cliente = r['nombre_cliente'] as String?;
      fecha = DateTime.parse(r['fecha_hora'] as String);
    }
    DateTime? ocupada;
    if (m['ocupada_desde'] != null) {
      ocupada = DateTime.parse(m['ocupada_desde'] as String);
    }
    return Mesa(
      id:        m['id'] as int,
      numero:    m['numero'] as int,
      estado:    m['estado'] as String,
      cliente:   cliente,
      fechaHora: fecha,
    );
  }
}

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({Key? key}) : super(key: key);

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  late Future<List<Mesa>> _mesasFuture;

  @override
  void initState() {
    super.initState();
    _mesasFuture = _fetchMesas();
  }

  /// Lee mesas y su última reserva si existe
  Future<List<Mesa>> _fetchMesas() async {
    final supa = Supabase.instance.client;
    try {
      final response = await supa
          .from('mesas')
          .select('id,numero,estado,ocupada_desde,reservas(nombre_cliente,fecha_hora)').order('numero', ascending: true);;
      final list = response as List<dynamic>;
      return list
          .map((e) => Mesa.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Si hay cualquier fallo (RLS, red, sintaxis…) cae aquí
      throw Exception('Error cargando mesas: $e');
    }
  }

  Future<void> _ocuparMesa(int mesaId) async {
    final supa = Supabase.instance.client;
    await supa
        .from('mesas')
        .update({
      'estado': 'OCUPADA',
      'ocupada_desde': DateTime.now().toIso8601String(),
    })
        .eq('id', mesaId);
    setState(() {
      _mesasFuture = _fetchMesas();
    });
  }

  /// Reserva la mesa: crea registro en reservas y marca mesa como reservada
  Future<void> _reservarMesa(Mesa mesa) async {
    final supa = Supabase.instance.client;
    await supa.from('reservas').insert({
      'mesa_id': mesa.id,
      'nombre_cliente': 'Raúl', // TODO: pedir nombre real
      'fecha_hora': DateTime.now().toIso8601String(),
      'estado': 'Pendiente',
    });
    await supa.from('mesas').update({'estado': 'RESERVADA'}).eq('id', mesa.id);
    setState(() {
      _mesasFuture = _fetchMesas();
    });
  }

  /// Libera la mesa: actualiza estado a libre
  Future<void> _liberarMesa(int mesaId) async {
    final supa = Supabase.instance.client;
    await supa.from('mesas').update({'estado': 'LIBRE', 'ocupada_desde': null}).eq('id', mesaId).select();
    setState(() {
      _mesasFuture = _fetchMesas();
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
              if (mesa.fechaHora != null) ...[
                const SizedBox(height: 8),
                Text('Hora: ${DateFormat('HH:mm').format(mesa.fechaHora!)}'),
              ],
              if (mesa.estado == 'RESERVADA' && mesa.cliente != null) ...[
                const SizedBox(height: 8),
                Text('Cliente: ${mesa.cliente!}'),
              ],
              if (mesa.estado == 'OCUPADA') ...[
                Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Hora: ${mesa.fechaHora != null ? DateFormat('HH:mm').format(mesa.fechaHora!) : '-'}'))
              ],
            ],
          ),
          actions: [
            if (mesa.estado == 'LIBRE')
              TextButton(
                onPressed: () async {
                  await _reservarMesa(mesa);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Reservar'),
              ),
              TextButton(
                onPressed: () async {
                  await _ocuparMesa(mesa.id);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Ocupar'),
              ),
            if (mesa.estado == 'OCUPADA')
              TextButton(
                onPressed: () async {
                  await _liberarMesa(mesa.id);
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
    return FutureBuilder<List<Mesa>>(
      future: _mesasFuture,
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
          children: mesas.map((mesa) {
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
    );
  }
}