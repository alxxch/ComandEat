// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plato.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlatoImpl _$$PlatoImplFromJson(Map<String, dynamic> json) => _$PlatoImpl(
  id: (json['id'] as num).toInt(),
  nombre: json['nombre'] as String,
  descripcion: json['descripcion'] as String?,
  precio: (json['precio'] as num).toDouble(),
  fotoUrl: json['foto_url'] as String?,
  categoriaId: (json['categoria_id'] as num).toInt(),
);

Map<String, dynamic> _$$PlatoImplToJson(_$PlatoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'descripcion': instance.descripcion,
      'precio': instance.precio,
      'foto_url': instance.fotoUrl,
      'categoria_id': instance.categoriaId,
    };
