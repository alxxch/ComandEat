import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/plato.dart';

final menuRepoProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

class HomeRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Plato>> getPlatos() async {
    final allPlatos =
        await _client
                .from('platos')
                .select('id,nombre,descripcion,precio,foto_url,categoria_id')
                .order('nombre')
            as List;
    final platos =
        allPlatos.map((e) => Plato.fromJson(e as Map<String, dynamic>)).toList();
    final allPlatosIngredientes =
        await _client
                .from('plato_ingrediente')
                .select('plato_id, ingrediente:ingredientes(id,nombre,es_alergeno)')
            as List;
    final Map<int, List<String>> tagsMap = {};
    for (final row in allPlatosIngredientes.cast<Map<String, dynamic>>()) {
      final int platoId = row['plato_id'] as int;
      final ingrediente = row['ingrediente'] as Map<String, dynamic>;
      if (ingrediente['es_alergeno'] as bool) {
        tagsMap.putIfAbsent(platoId, () => []).add(ingrediente['nombre'] as String);
      }
    }
    return platos.map((p) {
      final tags = tagsMap[p.id] ?? <String>[];
      return p.copyWith(allergenTags: tags);
    }).toList();
  }
}
