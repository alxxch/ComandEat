import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de Mesa y su reserva más reciente
class Mesa {
  final int id;
  final int numero;
  final String estado; // 'LIBRE', 'OCUPADA', 'RESERVADA'
  final DateTime? ocupadaDesde;
  final String? cliente;
  final DateTime? fechaReserva;

  Mesa({required this.id, required this.numero, required this.estado, this.ocupadaDesde, this.cliente, this.fechaReserva});

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
    final ocupada = m['ocupada_desde'] != null ? DateTime.parse(m['ocupada_desde'] as String) : null;
    return Mesa(id: m['id'] as int, numero: m['numero'] as int, estado: m['estado'] as String, ocupadaDesde: ocupada, cliente: cliente, fechaReserva: fecha);
  }
}

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({Key? key}) : super(key: key);

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  late Future<List<Mesa>> _mesasFuture;

  // Selectores dummy
  DateTime _selectedDate = DateTime.now();
  final List<String> _salas = ['Sala 1', 'Sala 2', 'Sala 3'];
  int _salaIndex = 0;
  final List<String> _franjas = ['14:00-15:00', '15:00-16:00', '16:00-17:00'];
  int _franjaIndex = 0;

  @override
  void initState() {
    super.initState();
    _mesasFuture = _fetchMesas();
  }

  /// Lee mesas y su última reserva si existe
  Future<List<Mesa>> _fetchMesas() async {
    final supa = Supabase.instance.client;
    try {
      final response = await supa.from('mesas').select('id,numero,estado,ocupada_desde,reservas(nombre_cliente,fecha_hora)').order('numero', ascending: true);
      final list = response as List<dynamic>;
      return list.map((e) => Mesa.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Si hay cualquier fallo (RLS, red, sintaxis…) cae aquí
      throw Exception('Error cargando mesas: $e');
    }
  }

  void _prevDate() => setState(() => _selectedDate = _selectedDate.subtract(Duration(days: 1)));

  void _nextDate() => setState(() => _selectedDate = _selectedDate.add(Duration(days: 1)));

  void _prevSala() => setState(() {
    if (_salaIndex > 0) _salaIndex--;
  });

  void _nextSala() => setState(() {
    if (_salaIndex < _salas.length - 1) _salaIndex++;
  });

  void _prevFranja() => setState(() {
    if (_franjaIndex > 0) _franjaIndex--;
  });

  void _nextFranja() => setState(() {
    if (_franjaIndex < _franjas.length - 1) _franjaIndex++;
  });

  Future<void> _ocuparMesa(Mesa mesa) async {
    final supa = Supabase.instance.client;
    await supa.from('mesas').update({'estado': 'OCUPADA', 'ocupada_desde': DateTime.now().toIso8601String()}).eq('id', mesa.id).select();
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
      'estado': 'ACTIVA',
    });
    await supa.from('mesas').update({'estado': 'RESERVADA'}).eq('id', mesa.id).select();
    setState(() {
      _mesasFuture = _fetchMesas();
    });
  }

  /// Confirma llegada: mantiene reserva y marca ocupada
  Future<void> _confirmarLlegada(Mesa mesa) async {
    final supa = Supabase.instance.client;
    await supa.from('mesas').update({'estado': 'OCUPADA', 'ocupada_desde': DateTime.now().toIso8601String()}).eq('id', mesa.id).select();
    await supa.from('reservas').delete().eq('mesa_id', mesa.id).select();
    setState(() {
      _mesasFuture = _fetchMesas();
    });
  }

  Future<void> _cancelarReserva(Mesa mesa) async {
    final supa = Supabase.instance.client;
    await supa.from('mesas').update({'estado': 'LIBRE', 'ocupada_desde': null}).eq('id', mesa.id).select();
    await supa.from('reservas').delete().eq('mesa_id', mesa.id).select();
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
              if (mesa.fechaReserva != null) ...[const SizedBox(height: 8), Text('Reservada: ${DateFormat('HH:mm').format(mesa.fechaReserva!.toLocal())}')],
              if (mesa.estado == 'RESERVADA' && mesa.cliente != null) ...[const SizedBox(height: 8), Text('Cliente: ${mesa.cliente!}')],
              if (mesa.estado == 'OCUPADA' && mesa.ocupadaDesde != null) ...[
                const SizedBox(height: 8),
                Text('Ocupada desde: ${DateFormat('HH:mm').format(mesa.ocupadaDesde!.toLocal())}'),
              ],
            ],
          ),
          actions: [
            if (mesa.estado == 'LIBRE') ...[
              TextButton(
                onPressed: () async {
                  await _reservarMesa(mesa);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Reservar'),
              ),
              TextButton(
                onPressed: () async {
                  await _ocuparMesa(mesa);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Ocupar'),
              ),
            ],
            if (mesa.estado == 'RESERVADA') ...[
              TextButton(
                onPressed: () async {
                  await _confirmarLlegada(mesa);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Confirmar llegada'),
              ),
              TextButton(
                onPressed: () async {
                  await _cancelarReserva(mesa);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancelar Reserva'),
              ),
            ],
            if (mesa.estado == 'OCUPADA')
              TextButton(
                onPressed: () async {
                  await _liberarMesa(mesa.id);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Liberar'),
              ),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cerrar')),
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
        // Selectores de fecha, sala y franja
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _SelectorButton(label: DateFormat('dd/MM/yyyy').format(_selectedDate), onPrev: _prevDate, onNext: _nextDate),
              const SizedBox(width: 12),
              _SelectorButton(label: _salas[_salaIndex], onPrev: _prevSala, onNext: _nextSala),
              const SizedBox(width: 12),
              _SelectorButton(label: _franjas[_franjaIndex], onPrev: _prevFranja, onNext: _nextFranja),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Grid de mesas
        Expanded(
          child: FutureBuilder<List<Mesa>>(
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
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                          child: Center(child: Text('Mesa ${mesa.numero}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ),
        // Leyenda de colores
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              _LegendItem(color: Color(0xFFA5D6A7), label: 'Libre'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFFBCAAA4), label: 'Reservada'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFFEF9A9A), label: 'Ocupada'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _SelectorButton({required this.label, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(4)),
    child: Row(
      children: [IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev), Text(label), IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext)],
    ),
  );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({Key? key, required this.color, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
