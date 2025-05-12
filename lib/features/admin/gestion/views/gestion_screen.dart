import 'package:flutter/material.dart';

import '../controllers/gestion_controller.dart';

class GestionScreen extends StatefulWidget {
  const GestionScreen({Key? key}) : super(key: key);

  @override
  State<GestionScreen> createState() => _GestionScreenState();
}

class _GestionScreenState extends State<GestionScreen> {
  late final GestionController ctr;

  @override
  void initState() {
    super.initState();
    ctr = GestionController(context);
    ctr.bind(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    ctr.unbind();
    ctr.dispose();
    super.dispose();
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
                key: ctr.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Agregar nuevo plato',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ctr.nombre,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del plato',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ctr.descripcion,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ctr.precio,
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
                      value: ctr.selectedCategoria,
                      items:
                          ctr.categorias
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => ctr.selectedCategoria = v),
                      validator: (v) => v == null ? 'Seleccione categoría' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: ctr.checkGuardar ? null : ctr.sendPlato,
                        child:
                            ctr.checkGuardar
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
