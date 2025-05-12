import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  final TextEditingController nombre = TextEditingController(text: 'Mesón Paco');
  final TextEditingController direccion = TextEditingController(text: 'Calle Mayor, 123');
  final TextEditingController telefono = TextEditingController(text: '+34 600 123 456');
  bool isSaving = false;

  Future<void> savePerfil(BuildContext context) async {
    isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil guardado - No implementado')));

    isSaving = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nombre.dispose();
    direccion.dispose();
    telefono.dispose();
    super.dispose();
  }
}
