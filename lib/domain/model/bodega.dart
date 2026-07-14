class Bodega {
  final String id;
  final String nombre;
  final String? direccion;
  final bool activa;

  Bodega({
    required this.id,
    required this.nombre,
    this.direccion,
    this.activa = true,
  });

  Bodega copyWith({String? id, String? nombre, String? direccion, bool? activa}) {
    return Bodega(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      activa: activa ?? this.activa,
    );
  }

  factory Bodega.fromJson(Map<String, dynamic> json) {
    return Bodega(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'],
      activa: json['activa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'direccion': direccion,
    'activa': activa,
  };
}