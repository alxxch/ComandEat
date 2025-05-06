import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../controllers/pedido_controller.dart';
import '../../../../core/models/estado_pedido.dart';

class EstadoPedidoScreen extends ConsumerStatefulWidget {
  const EstadoPedidoScreen({super.key, required this.pedidoId});

  final int pedidoId;

  @override
  ConsumerState<EstadoPedidoScreen> createState() => _EstadoPedidoScreenState();
}

class _EstadoPedidoScreenState extends ConsumerState<EstadoPedidoScreen> {
  late final Stopwatch _watch;
  late Timer _ticker;

  @override
  void initState() {
    super.initState();
    _watch = Stopwatch()..start();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estadoAsync = ref.watch(pedidoControllerProvider(widget.pedidoId));

    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${widget.pedidoId}')),
      body: estadoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (estado) {
          final pasos = EstadoPedido.values;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Lottie.asset(
                      estado.animationAsset,
                      key: ValueKey(estado),
                      width: 140,
                      repeat: true,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  estado.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // centra stepper
                  children:
                      pasos.map((p) {
                        final reached = p.index <= estado.index;
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  reached
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                              child: Icon(
                                p.icon,
                                size: 16,
                                color:
                                    reached
                                        ? Colors.white
                                        : Colors.grey.shade600,
                              ),
                            ),
                            if (p != pasos.last)
                              SizedBox(
                                height: 24,
                                child: VerticalDivider(
                                  color:
                                      reached
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.grey.shade300,
                                  thickness: 2,
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                ),
                const SizedBox(height: 32),
                Text(
                  _formatDuration(_watch.elapsed),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text('Tiempo transcurrido'),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
