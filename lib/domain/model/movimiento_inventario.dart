// lib/domain/model/movimiento_inventario.dart

class MovimientoInventario {
  final int? id;
  final int productoId;
  final String? productoNombre;
  final String? productoCategoria;
  final int? proveedorId;
  final String? proveedorNombre;
  final String tipo; // 'ENTRADA', 'SALIDA', 'AJUSTE_POS', 'AJUSTE_NEG'
  final String? tipoDisplay;
  final int cantidad;
  final String? motivo;
  final String? usuario;
  final DateTime? creadoEn;

  MovimientoInventario({
    this.id,
    required this.productoId,
    this.productoNombre,
    this.productoCategoria,
    this.proveedorId,
    this.proveedorNombre,
    required this.tipo,
    this.tipoDisplay,
    required this.cantidad,
    this.motivo,
    this.usuario,
    this.creadoEn,
  });

  factory MovimientoInventario.fromJson(Map<String, dynamic> json) {
    return MovimientoInventario(
      id: json['id'],
      productoId: json['producto'],
      productoNombre: json['producto_nombre'],
      productoCategoria: json['producto_categoria'],
      proveedorId: json['proveedor'],
      proveedorNombre: json['proveedor_nombre'],
      tipo: json['tipo'],
      tipoDisplay: json['tipo_display'],
      cantidad: json['cantidad'] ?? 1,
      motivo: json['motivo'],
      usuario: json['usuario'],
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto': productoId,
      'tipo': tipo,
      'cantidad': cantidad,
      if (proveedorId != null) 'proveedor': proveedorId,
      if (motivo != null && motivo!.isNotEmpty) 'motivo': motivo,
    };
  }
}