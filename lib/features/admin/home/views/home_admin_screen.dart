import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de Mesa
class Mesa {
  final int id;
  final int numero;
  final String estado; // 'libre', 'ocupada', 'reservada'
  final String? cliente;
  final DateTime? fechaHora;

  Mesa({required this.id, required this.numero, required this.estado, this.cliente, this.fechaHora});

  factory Mesa.fromMap(Map<String, dynamic> m) {
    final resList = m['reservas'] as List<dynamic>?; // rel
    String? cliente;
    DateTime? fecha;
    if (resList != null && resList.isNotEmpty) {
      final r = resList.first as Map<String, dynamic>;
      cliente = r['nombre_cliente'] as String?;
      fecha = DateTime.parse(r['fecha_hora'] as String);
    }
    return Mesa(id: m['id'] as int, numero: m['numero'] as int, estado: m['estado'] as String, cliente: cliente, fechaHora: fecha);
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

  Future<List<Mesa>> _fetchMesas() async {
    final supa = Supabase.instance.client;
    try {
      // 1️⃣ Obtienes los datos directamente
      final response = await supa
          .from('mesas')
          .select('''
    id,
    numero,
    estado,
    reservas(
      nombre_cliente,
      fecha_hora
    )
  ''')
          .order('numero');

      // 2️⃣ Los conviertes a tu modelo
      final list = response as List<dynamic>;
      return list.map((e) => Mesa.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Si hay cualquier fallo (RLS, red, sintaxis…) cae aquí
      throw Exception('Error cargando mesas: $e');
    }
  }

  void _showMesaDialog(Mesa mesa) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) {
        return AlertDialog(
          title: Text('Mesa ${mesa.numero}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estado: ${mesa.estado.toUpperCase()}'),
              if (mesa.estado == 'ocupada' || mesa.estado == 'reservada')
                Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Hora: ${mesa.fechaHora != null ? DateFormat('HH:mm').format(mesa.fechaHora!) : '-'}')),
              if (mesa.estado == 'reservada' && mesa.cliente != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Cliente: ${mesa.cliente!}')),
            ],
          ),
          actions: [
            if (mesa.estado == 'libre')
              TextButton(
                onPressed: () {
                  // TODO: implementar función reservar
                  Navigator.pop(context);
                },
                child: const Text('Reservar'),
              ),
            if (mesa.estado == 'ocupada')
              TextButton(
                onPressed: () {
                  // TODO: implementar función liberar
                  Navigator.pop(context);
                },
                child: const Text('Liberar'),
              ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
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
          children:
              mesas.map((mesa) {
                Color bg;
                switch (mesa.estado) {
                  case 'ocupada':
                    bg = Colors.red.shade200;
                    break;
                  case 'reservada':
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
    );
  }
}
