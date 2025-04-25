import 'package:freezed_annotation/freezed_annotation.dart';

part 'plato.freezed.dart';
part 'plato.g.dart';
@freezed
class Plato with _$Plato {
  const factory Plato({
    required int id,

    required String nombre,

    String? descripcion,

    required double precio,

    @JsonKey(name: 'foto_url') String? fotoUrl,
  }) = _Plato;

  factory Plato.fromJson(Map<String, dynamic> json) => _$PlatoFromJson(json);
}