import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GestionScreen extends StatefulWidget {
  const GestionScreen({Key? key}) : super(key: key);

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ctrNombre = TextEditingController();
  final ctrDescripcion = TextEditingController();
  final ctrPrecio = TextEditingController();
  String? _selectCategoria;
  final List<String> _categorias = const ['Entrantes', 'Pizzas', 'Postres', 'Bebidas'];
  bool _checkGuardar = false;

  @override
  void dispose() {
    _ctrNombre.dispose();
    ctrDescripcion.dispose();
    ctrPrecio.dispose();
    super.dispose();
  }

  Future<void> _sendPlato() async {
    if (!_formKey.currentState!.validate() || _selectCategoria == null) return;
    setState(() => _checkGuardar = true);
    final sql = Supabase.instance.client;
    final categoriaId = _categorias.indexOf(_selectCategoria!) + 1;
    try {
      final data =
          await sql.from('platos').insert({
            'nombre': _ctrNombre.text.trim(),
            'descripcion': ctrDescripcion.text.trim(),
            'precio': double.parse(ctrPrecio.text),
            'categoria_id': categoriaId,
          }).select();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Plato agregado con éxito')));
      _formKey.currentState!.reset();
      _ctrNombre.clear();
      ctrDescripcion.clear();
      ctrPrecio.clear();
      setState(() => _selectCategoria = null);
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar plato: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    } finally {
      if (mounted) setState(() => _checkGuardar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión del Restaurante',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Agregar nuevo plato',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ctrNombre,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del plato',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ctrDescripcion,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ctrPrecio,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixText: '€ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        final value = double.tryParse(v);
                        if (value == null) return 'Número inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectCategoria,
                      items:
                          _categorias
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _selectCategoria = v),
                      validator: (v) => v == null ? 'Seleccione categoría' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkGuardar ? null : _sendPlato,
                        child:
                            _checkGuardar
                                ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Guardar plato'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
