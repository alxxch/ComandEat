import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GestionController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nombre = TextEditingController();
  final TextEditingController descripcion = TextEditingController();
  final TextEditingController precio = TextEditingController();
  String? selectedCategoria;
  bool checkGuardar = false;
  final List<String> categorias = const ['Entrantes', 'Pizzas', 'Postres', 'Bebidas'];
  final BuildContext context;

  GestionController(this.context);

  Future<void> sendPlato() async {
    if (!formKey.currentState!.validate() || selectedCategoria == null) return;
    checkGuardar = true;
    _notify();
    final sql = Supabase.instance.client;
    final categoriaId = categorias.indexOf(selectedCategoria!) + 1;
    try {
      await sql.from('platos').insert({
        'nombre': nombre.text.trim(),
        'descripcion': descripcion.text.trim(),
        'precio': double.parse(precio.text),
        'categoria_id': categoriaId,
      }).select();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Plato agregado con éxito')));
      formKey.currentState!.reset();
      nombre.clear();
      descripcion.clear();
      precio.clear();
      selectedCategoria = null;
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar plato: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    } finally {
      checkGuardar = false;
      _notify();
    }
  }

  VoidCallback? _onUpdate;

  void bind(VoidCallback listener) => _onUpdate = listener;

  void unbind() => _onUpdate = null;

  void _notify() => _onUpdate?.call();

  void dispose() {
    nombre.dispose();
    descripcion.dispose();
    precio.dispose();
  }
}
