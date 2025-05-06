import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({Key? key}) : super(key: key);

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  // State para selectores
  DateTime _selectedDate = DateTime.now();
  final List<String> _salas = ['Sala 1', 'Sala 2', 'Sala 3'];
  int _salaIndex = 0;
  final List<String> _franjas = ['14:00-15:00', '15:00-16:00', '16:00-17:00'];
  int _franjaIndex = 0;

  void _prevDate() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDate() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  void _prevSala() {
    setState(() {
      if (_salaIndex > 0) _salaIndex--;
    });
  }

  void _nextSala() {
    setState(() {
      if (_salaIndex < _salas.length - 1) _salaIndex++;
    });
  }

  void _prevFranja() {
    setState(() {
      if (_franjaIndex > 0) _franjaIndex--;
    });
  }

  void _nextFranja() {
    setState(() {
      if (_franjaIndex < _franjas.length - 1) _franjaIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selectores
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Selector de fecha
            _SelectorButton(
              label: dateStr,
              onPrev: _prevDate,
              onNext: _nextDate,
            ),
            const SizedBox(width: 16),
            // Selector de sala
            _SelectorButton(
              label: _salas[_salaIndex],
              onPrev: _prevSala,
              onNext: _nextSala,
            ),
            const SizedBox(width: 16),
            // Selector de franja horaria
            _SelectorButton(
              label: _franjas[_franjaIndex],
              onPrev: _prevFranja,
              onNext: _nextFranja,
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Rejilla de mesas
        Expanded(
          child: GridView.count(
            crossAxisCount: 5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: List.generate(15, (index) {
              // Estados de prueba cíclicos: 0=Libre,1=Ocupado,2=Reservado
              final stateIndex = index % 3;
              Color bg;
              switch (stateIndex) {
                case 0:
                  bg = Colors.green.shade200;
                  break;
                case 1:
                  bg = Colors.red.shade200;
                  break;
                default:
                  bg = Colors.brown.shade200;
              }
              return GestureDetector(
                onTap: () {
                  // TODO: acción al pulsar mesa
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Mesa ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        // Leyenda de estados
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendItem(color: Colors.green.shade200, label: 'Libre'),
              const SizedBox(width: 12),
              _LegendItem(color: Colors.red.shade200, label: 'Ocupada'),
              const SizedBox(width: 12),
              _LegendItem(color: Colors.brown.shade200, label: 'Reservada'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget para selector con prev/next
class _SelectorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _SelectorButton({
    Key? key,
    required this.label,
    required this.onPrev,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

/// Widget para ítem de leyenda
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({Key? key, required this.color, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
