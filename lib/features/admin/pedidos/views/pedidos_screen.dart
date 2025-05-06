import 'package:flutter/material.dart';

/// Pantalla de Pedidos entrantes para el administrador
class PedidosScreen extends StatelessWidget {
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Reemplazar con datos reales de Supabase
    final pedidosDummy = List.generate(12, (i) => {
      'id': i + 1,
      'mesa': (i % 15) + 1,
      'hora': '14:${(i * 5) % 60}'.padLeft(2, '0'),
      'estado': 'Pendiente',
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Pedidos Entrantes',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),

        // Lista de pedidos
        Expanded(
          child: ListView.separated(
            itemCount: pedidosDummy.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final pedido = pedidosDummy[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      pedido['mesa'].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('Pedido #${pedido['id']}'),
                  subtitle: Text('Hora: ${pedido['hora']}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // TODO: Acción para confirmar o ver detalle
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Ver'),
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
