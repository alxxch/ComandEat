// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plato.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Plato _$PlatoFromJson(Map<String, dynamic> json) {
  return _Plato.fromJson(json);
}

/// @nodoc
mixin _$Plato {
  int get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;
  double get precio => throw _privateConstructorUsedError;
  @JsonKey(name: 'foto_url')
  String? get fotoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'categoria_id')
  int get categoriaId => throw _privateConstructorUsedError;

  /// Serializes this Plato to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Plato
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlatoCopyWith<Plato> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlatoCopyWith<$Res> {
  factory $PlatoCopyWith(Plato value, $Res Function(Plato) then) =
      _$PlatoCopyWithImpl<$Res, Plato>;
  @useResult
  $Res call({
    int id,
    String nombre,
    String? descripcion,
    double precio,
    @JsonKey(name: 'foto_url') String? fotoUrl,
    @JsonKey(name: 'categoria_id') int categoriaId,
  });
}

/// @nodoc
class _$PlatoCopyWithImpl<$Res, $Val extends Plato>
    implements $PlatoCopyWith<$Res> {
  _$PlatoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Plato
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? descripcion = freezed,
    Object? precio = null,
    Object? fotoUrl = freezed,
    Object? categoriaId = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            nombre:
                null == nombre
                    ? _value.nombre
                    : nombre // ignore: cast_nullable_to_non_nullable
                        as String,
            descripcion:
                freezed == descripcion
                    ? _value.descripcion
                    : descripcion // ignore: cast_nullable_to_non_nullable
                        as String?,
            precio:
                null == precio
                    ? _value.precio
                    : precio // ignore: cast_nullable_to_non_nullable
                        as double,
            fotoUrl:
                freezed == fotoUrl
                    ? _value.fotoUrl
                    : fotoUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            categoriaId:
                null == categoriaId
                    ? _value.categoriaId
                    : categoriaId // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlatoImplCopyWith<$Res> implements $PlatoCopyWith<$Res> {
  factory _$$PlatoImplCopyWith(
    _$PlatoImpl value,
    $Res Function(_$PlatoImpl) then,
  ) = __$$PlatoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String nombre,
    String? descripcion,
    double precio,
    @JsonKey(name: 'foto_url') String? fotoUrl,
    @JsonKey(name: 'categoria_id') int categoriaId,
  });
}

/// @nodoc
class __$$PlatoImplCopyWithImpl<$Res>
    extends _$PlatoCopyWithImpl<$Res, _$PlatoImpl>
    implements _$$PlatoImplCopyWith<$Res> {
  __$$PlatoImplCopyWithImpl(
    _$PlatoImpl _value,
    $Res Function(_$PlatoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Plato
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? descripcion = freezed,
    Object? precio = null,
    Object? fotoUrl = freezed,
    Object? categoriaId = null,
  }) {
    return _then(
      _$PlatoImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        nombre:
            null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                    as String,
        descripcion:
            freezed == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                    as String?,
        precio:
            null == precio
                ? _value.precio
                : precio // ignore: cast_nullable_to_non_nullable
                    as double,
        fotoUrl:
            freezed == fotoUrl
                ? _value.fotoUrl
                : fotoUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        categoriaId:
            null == categoriaId
                ? _value.categoriaId
                : categoriaId // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlatoImpl implements _Plato {
  const _$PlatoImpl({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    @JsonKey(name: 'foto_url') this.fotoUrl,
    @JsonKey(name: 'categoria_id') required this.categoriaId,
  });

  factory _$PlatoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlatoImplFromJson(json);

  @override
  final int id;
  @override
  final String nombre;
  @override
  final String? descripcion;
  @override
  final double precio;
  @override
  @JsonKey(name: 'foto_url')
  final String? fotoUrl;
  @override
  @JsonKey(name: 'categoria_id')
  final int categoriaId;

  @override
  String toString() {
    return 'Plato(id: $id, nombre: $nombre, descripcion: $descripcion, precio: $precio, fotoUrl: $fotoUrl, categoriaId: $categoriaId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlatoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.precio, precio) || other.precio == precio) &&
            (identical(other.fotoUrl, fotoUrl) || other.fotoUrl == fotoUrl) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nombre,
    descripcion,
    precio,
    fotoUrl,
    categoriaId,
  );

  /// Create a copy of Plato
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlatoImplCopyWith<_$PlatoImpl> get copyWith =>
      __$$PlatoImplCopyWithImpl<_$PlatoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlatoImplToJson(this);
  }
}

abstract class _Plato implements Plato {
  const factory _Plato({
    required final int id,
    required final String nombre,
    final String? descripcion,
    required final double precio,
    @JsonKey(name: 'foto_url') final String? fotoUrl,
    @JsonKey(name: 'categoria_id') required final int categoriaId,
  }) = _$PlatoImpl;

  factory _Plato.fromJson(Map<String, dynamic> json) = _$PlatoImpl.fromJson;

  @override
  int get id;
  @override
  String get nombre;
  @override
  String? get descripcion;
  @override
  double get precio;
  @override
  @JsonKey(name: 'foto_url')
  String? get fotoUrl;
  @override
  @JsonKey(name: 'categoria_id')
  int get categoriaId;

  /// Create a copy of Plato
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlatoImplCopyWith<_$PlatoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
