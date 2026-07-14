// lib/domain/model/categoria.dart

class Categoria {
  final int? id;
  final String nombre;
  final String slug;
  final String descripcion;
  final bool activa;
  final int? totalProductos;
  final DateTime? creadoEn;

  Categoria({
    this.id,
    required this.nombre,
    required this.slug,
    this.descripcion = '',
    this.activa = true,
    this.totalProductos,
    this.creadoEn,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
      slug: json['slug'],
      descripcion: json['descripcion'] ?? '',
      activa: json['activa'] ?? true,
      totalProductos: json['total_productos'],
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'slug': slug,
      'descripcion': descripcion,
      'activa': activa,
      // 'total_productos' y 'creado_en' son read_only en Django
    };
  }
}