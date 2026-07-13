import 'orden_compra_detalle.dart';

class OrdenCompra {
  final int? id;
  final String? codigoOrden; 
  final int proveedorId; 
  final String? proveedorNombre; 
  final String? usuario; 
  final String estado;
  final String? estadoDisplay; 
  final double totalEstimado;
  final List<OrdenCompraDetalle> detalles;
  final DateTime? creadoEn; 

  OrdenCompra({
    this.id,
    this.codigoOrden,
    required this.proveedorId,
    this.proveedorNombre,
    this.usuario,
    this.estado = 'PENDIENTE',
    this.estadoDisplay,
    required this.totalEstimado,
    required this.detalles,
    this.creadoEn,
  });

  factory OrdenCompra.fromJson(Map<String, dynamic> json) {
    var detallesList = json['detalles'] as List? ?? [];

    return OrdenCompra(
      id: json['id'],
      codigoOrden: json['codigo_orden'],
      proveedorId: json['proveedor'],
      proveedorNombre: json['proveedor_nombre'],
      usuario: json['usuario'],
      estado: json['estado'] ?? 'PENDIENTE',
      estadoDisplay: json['estado_display'],
      totalEstimado: double.tryParse(json['total_estimado'].toString()) ?? 0.0,
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en']) : null,
      detalles: detallesList.map((d) => OrdenCompraDetalle.fromJson(d)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'proveedor': proveedorId,
      'estado': estado,
      'total_estimado': totalEstimado.toStringAsFixed(2),
      'detalles': detalles.map((d) => d.toJson()).toList(),
    };
  }
}