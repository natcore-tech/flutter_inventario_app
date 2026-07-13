class OrdenCompraDetalle {
  final int? id;
  final int productoId; 
  final String? productoNombre; 
  final int cantidad;
  final double precioUnitarioCompra;

  OrdenCompraDetalle({
    this.id,
    required this.productoId,
    this.productoNombre,
    required this.cantidad,
    required this.precioUnitarioCompra,
  });

  factory OrdenCompraDetalle.fromJson(Map<String, dynamic> json) {
    return OrdenCompraDetalle(
      id: json['id'],
      productoId: json['producto'],
      productoNombre: json['producto_nombre'],
      cantidad: json['cantidad'] ?? 0,
      precioUnitarioCompra: double.tryParse(json['precio_unitario_compra'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto': productoId,
      'cantidad': cantidad,
      'precio_unitario_compra': precioUnitarioCompra.toStringAsFixed(2),
    };
  }
}