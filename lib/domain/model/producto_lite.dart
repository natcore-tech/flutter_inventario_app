// lib/presentation/domain/model/producto_lite.dart

class ProductoLite {
  final int     id;
  final String  nombre;
  final double  precio;
  final int     stock;
  final bool    esActivo;

  const ProductoLite({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.esActivo,
  });

  bool get enStock => stock > 0;

  factory ProductoLite.fromJson(Map<String, dynamic> json) => ProductoLite(
        id:       json['id'] as int,
        nombre:   json['nombre'] as String,
        precio:   double.parse(json['precio'].toString()),
        stock:    json['stock'] as int,
        esActivo: json['es_activo'] as bool? ?? true,
      );
}