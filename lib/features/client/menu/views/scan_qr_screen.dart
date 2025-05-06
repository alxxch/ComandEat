import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/services/providers.dart';

class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  late final MobileScannerController _controller;
  bool _found = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      torchEnabled: false,
      formats: [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(Barcode barcode, MobileScannerArguments? args) {
    if (_found) return;            // evita doble disparo
    final raw = barcode.rawValue;
    if (raw == null) return;

    final mesaId = int.tryParse(raw);
    if (mesaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR no válido para mesa')),
      );
      return;
    }
    _found = true;
    // guardamos la mesa y navegamos
    ref.read(mesaIdProvider.notifier).state = mesaId;
    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanea el QR de tu mesa'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            allowDuplicates: false,
            onDetect: _onDetect,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FloatingActionButton(
                onPressed: () => _controller.toggleTorch(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                backgroundColor: Colors.white,
                child: ValueListenableBuilder<TorchState>(
                  valueListenable: _controller.torchState,
                  builder: (_, state, __) => Icon(
                      state == TorchState.off ? Icons.flash_off : Icons.flash_on
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
