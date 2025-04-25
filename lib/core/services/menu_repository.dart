import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plato.dart';

final menuRepoProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

class MenuRepository {
  MenuRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Plato>> obtenerPlatos() async {
    final data = await _client
        .from('platos')
        .select()
        .order('nombre', ascending: true);

    return (data as List)
        .map((e) => Plato.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Plato>> obtenerPlatosPorIngrediente(int ingredienteId) async {
    final data = await _client.rpc('platos_por_ingrediente', params: {
      'p_ingrediente_id': ingredienteId,
    });

    return (data as List)
        .map((e) => Plato.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> crearPlato(Plato p) async {
    await _client.from('platos').insert(p.toJson()..remove('id'));
  }
}