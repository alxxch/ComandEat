import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Mesa {
  final int id;
  final int numero;
  final String estado;
  final DateTime? ocupadaDesde;
  final String? cliente;
  final DateTime? fechaReserva;

  Mesa({
    required this.id,
    required this.numero,
    required this.estado,
    this.ocupadaDesde,
    this.cliente,
    this.fechaReserva,
  });

  factory Mesa.fromMap(Map<String, dynamic> m) {
    final lstReservas = m['reservas'] as List<dynamic>?;
    String? cliente;
    DateTime? fecha;
    if (lstReservas != null && lstReservas.isNotEmpty) {
      final r = lstReservas.first as Map<String, dynamic>;
      cliente = r['nombre_cliente'] as String?;
      fecha = DateTime.parse(r['fecha_hora'] as String);
    }
    final ocupada =
        m['ocupada_desde'] != null ? DateTime.parse(m['ocupada_desde'] as String) : null;
    return Mesa(
      id: m['id'] as int,
      numero: m['numero'] as int,
      estado: m['estado'] as String,
      ocupadaDesde: ocupada,
      cliente: cliente,
      fechaReserva: fecha,
    );
  }
}

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({Key? key}) : super(key: key);

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  late Future<List<Mesa>> _lstMesas;
  DateTime _selectedDate = DateTime.now();
  final List<String> _salas = ['Sala 1', 'Sala 2', 'Sala 3'];
  int _salaIndex = 0;
  final List<String> _horas = ['14:00-15:00', '15:00-16:00', '16:00-17:00'];
  int _horasIndex = 0;

  @override
  void initState() {
    super.initState();
    _lstMesas = _getMesas();
  }

  Future<List<Mesa>> _getMesas() async {
    final sql = Supabase.instance.client;
    try {
      final resultado = await sql
          .from('mesas')
          .select('id,numero,estado,ocupada_desde,reservas(nombre_cliente,fecha_hora)')
          .order('numero', ascending: true);
      final list = resultado as List<dynamic>;
      return list.map((e) => Mesa.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error cargando mesas: $e');
    }
  }

  void _prevDate() =>
      setState(() => _selectedDate = _selectedDate.subtract(Duration(days: 1)));

  void _nextDate() =>
      setState(() => _selectedDate = _selectedDate.add(Duration(days: 1)));

  void _prevSala() => setState(() {
    if (_salaIndex > 0) _salaIndex--;
  });

  void _nextSala() => setState(() {
    if (_salaIndex < _salas.length - 1) _salaIndex++;
  });

  void _prevFranja() => setState(() {
    if (_horasIndex > 0) _horasIndex--;
  });

  void _nextFranja() => setState(() {
    if (_horasIndex < _horas.length - 1) _horasIndex++;
  });

  Future<void> _ocuparMesa(Mesa mesa) async {
    final sql = Supabase.instance.client;
    await sql
        .from('mesas')
        .update({'estado': 'OCUPADA', 'ocupada_desde': DateTime.now().toIso8601String()})
        .eq('id', mesa.id)
        .select();
    setState(() {
      _lstMesas = _getMesas();
    });
  }

  Future<void> _reservarMesa(Mesa mesa) async {
    final List<String> lstNombres = [
      'Raúl',
      'María',
      'José',
      'Ana',
      'Luis',
      'Laura',
      'Pedro',
    ];
    final sql = Supabase.instance.client;
    await sql.from('reservas').insert({
      'mesa_id': mesa.id,
      'nombre_cliente': lstNombres[Random().nextInt(7)],
      'fecha_hora': DateTime.now().toIso8601String(),
      'estado': 'ACTIVA',
    });
    await sql.from('mesas').update({'estado': 'RESERVADA'}).eq('id', mesa.id).select();
    setState(() {
      _lstMesas = _getMesas();
    });
  }

  Future<void> _confirmarLlegada(Mesa mesa) async {
    final sql = Supabase.instance.client;
    await sql
        .from('mesas')
        .update({'estado': 'OCUPADA', 'ocupada_desde': DateTime.now().toIso8601String()})
        .eq('id', mesa.id)
        .select();
    await sql.from('reservas').delete().eq('mesa_id', mesa.id).select();
    setState(() {
      _lstMesas = _getMesas();
    });
  }

  Future<void> _cancelarReserva(Mesa mesa) async {
    final sql = Supabase.instance.client;
    await sql
        .from('mesas')
        .update({'estado': 'LIBRE', 'ocupada_desde': null})
        .eq('id', mesa.id)
        .select();
    await sql.from('reservas').delete().eq('mesa_id', mesa.id).select();
    setState(() {
      _lstMesas = _getMesas();
    });
  }

  Future<void> _liberarMesa(int mesaId) async {
    final sql = Supabase.instance.client;
    await sql
        .from('mesas')
        .update({'estado': 'LIBRE', 'ocupada_desde': null})
        .eq('id', mesaId)
        .select();
    setState(() {
      _lstMesas = _getMesas();
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
                lblTexto: DateFormat('dd/MM/yyyy').format(_selectedDate),
                anterior: _prevDate,
                siguiente: _nextDate,
              ),
              const SizedBox(width: 12),
              _btnSelector(
                lblTexto: _salas[_salaIndex],
                anterior: _prevSala,
                siguiente: _nextSala,
              ),
              const SizedBox(width: 12),
              _btnSelector(
                lblTexto: _horas[_horasIndex],
                anterior: _prevFranja,
                siguiente: _nextFranja,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<Mesa>>(
            future: _lstMesas,
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
