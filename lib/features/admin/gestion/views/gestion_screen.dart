import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GestionScreen extends StatefulWidget {
  const GestionScreen({Key? key}) : super(key: key);

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  String? _selectedCategoria;
  final List<String> _categorias = const ['Entrantes', 'Pizzas', 'Postres', 'Bebidas'];
  bool _saving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategoria == null) return;
    setState(() => _saving = true);
    final supa = Supabase.instance.client;
    final categoriaId = _categorias.indexOf(_selectedCategoria!) + 1;
    final res = await supa
        .from('platos')
        .insert({
      'nombre': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'precio': double.parse(_precioController.text),
      'categoria_id': categoriaId,
    });
    setState(() => _saving = false);
    if (res.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${res.error!.message}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plato agregado con éxito')));
      _formKey.currentState!.reset();
      _nombreController.clear();
      _descripcionController.clear();
      _precioController.clear();
      setState(() => _selectedCategoria = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gestión del Restaurante', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),

          // Formulario para agregar plato
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
                    const Text('Agregar nuevo plato', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre del plato', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    // Descripción
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    // Precio
                    TextFormField(
                      controller: _precioController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio', prefixText: '€ ', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        final val = double.tryParse(v);
                        if (val == null) return 'Número inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // Categoría
                    DropdownButtonFormField<String>(
                      value: _selectedCategoria,
                      items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                      onChanged: (v) => setState(() => _selectedCategoria = v),
                      validator: (v) => v == null ? 'Seleccione categoría' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        child:
                            _saving
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
