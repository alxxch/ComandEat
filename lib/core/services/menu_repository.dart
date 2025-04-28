import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plato.dart';

final menuRepoProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

class MenuRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Plato>> obtenerPlatos() async {
    final platosRaw = await _client
        .from('platos')
        .select('id,nombre,descripcion,precio,foto_url,categoria_id')
        .order('nombre') as List;

    final platos = platosRaw
        .map((e) => Plato.fromJson(e as Map<String, dynamic>))
        .toList();

    final piRaw = await _client
        .from('plato_ingrediente')
        .select('plato_id, ingrediente:ingredientes(id,nombre,es_alergeno)')
    as List;

    final Map<int, List<String>> tagsMap = {};
    for (final row in piRaw.cast<Map<String, dynamic>>()) {
      final int pid = row['plato_id'] as int;
      final ing  = row['ingrediente'] as Map<String, dynamic>;
      if (ing['es_alergeno'] as bool) {
        tagsMap.putIfAbsent(pid, () => []).add(ing['nombre'] as String);
      }
    }

    return platos.map((p) {
      final tags = tagsMap[p.id] ?? <String>[];
      return p.copyWith(allergenTags: tags);
    }).toList();
  }
}