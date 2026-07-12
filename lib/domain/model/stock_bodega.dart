class StockBodega {
  final String id;
  final String bodegaId;
  final String? bodegaNombre;
  final String productoId;
  final String? productoNombre;
  final int cantidad;

  StockBodega({
    required this.id,
    required this.bodegaId,
    this.bodegaNombre,
    required this.productoId,
    this.productoNombre,
    required this.cantidad,
  });

  StockBodega copyWith({String? id, String? bodegaId, String? bodegaNombre, String? productoId, String? productoNombre, int? cantidad}) {
    return StockBodega(
      id: id ?? this.id,
      bodegaId: bodegaId ?? this.bodegaId,
      bodegaNombre: bodegaNombre ?? this.bodegaNombre,
      productoId: productoId ?? this.productoId,
      productoNombre: productoNombre ?? this.productoNombre,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  factory StockBodega.fromJson(Map<String, dynamic> json) {
    return StockBodega(
      id: json['id']?.toString() ?? '',
      bodegaId: json['bodega']?.toString() ?? '',
      bodegaNombre: json['bodega_nombre'],
      productoId: json['producto']?.toString() ?? '',
      productoNombre: json['producto_nombre'],
      cantidad: json['cantidad'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'bodega': bodegaId,
    'producto': productoId,
    'cantidad': cantidad,
  };
}