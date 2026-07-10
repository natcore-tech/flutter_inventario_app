class Producto {
  final String id;
  final String sku;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String marcaId;
  final String categoriaId;
  final String unidadMedidaId;
  final String? imageUrl;
  final bool activo;

Producto({
    required this.id,
    required this.sku,
    required this.nombre,
    required this.precio,
    required this.marcaId,
    required this.categoriaId,
    required this.unidadMedidaId,
    this.descripcion,
    this.imageUrl,
    this.activo = true,
});

Producto copyWith({
    String? id,
    String? sku,
    String? nombre,
    String? descripcion,
    double? precio,
    String? marcaId,
    String? categoriaId,
    String? unidadMedidaId,
    String? imageUrl,
    bool? activo,
}) {
    return Producto(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      marcaId: marcaId ?? this.marcaId,
      categoriaId: categoriaId ?? this.categoriaId,
      unidadMedidaId: unidadMedidaId ?? this.unidadMedidaId,
      imageUrl: imageUrl ?? this.imageUrl,
      activo: activo ?? this.activo,
    );
  }
}

factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? json['_id'] ?? '',
      sku: json['sku'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precio: (json['precio'] ?? 0).toDouble(),
      marcaId: json['marcaId'] ?? '',
      categoriaId: json['categoriaId'] ?? '',
      unidadMedidaId: json['unidadMedidaId'] ?? '',
      imageUrl: json['imageUrl'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'marcaId': marcaId,
      'categoriaId': categoriaId,
      'unidadMedidaId': unidadMedidaId,
      'imageUrl': imageUrl,
      'activo': activo,
    };
  }