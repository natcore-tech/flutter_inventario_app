// lib/presentation/domain/model/cotizacion.dart

class CotizacionDetalle {
  final int    productoId;
  final int    cantidad;
  final double precioPropuesto;

  const CotizacionDetalle({
    required this.productoId,
    required this.cantidad,
    required this.precioPropuesto,
  });

  double get subtotal => cantidad * precioPropuesto;

  factory CotizacionDetalle.fromJson(Map<String, dynamic> json) => CotizacionDetalle(
        productoId:      json['producto'] as int,
        cantidad:        json['cantidad'] as int,
        precioPropuesto: double.parse(json['precio_propuesto'].toString()),
      );

  Map<String, dynamic> toPayload() => {
        'producto':         productoId,
        'cantidad':         cantidad,
        'precio_propuesto': precioPropuesto,
      };
}

class Cotizacion {
  final int    id;
  final int    proveedorId;
  final String codigoCotizacion;
  final DateTime fechaEmision;
  final DateTime fechaValidez;
  final double totalPropuesto;
  final List<CotizacionDetalle> detalles;

  const Cotizacion({
    required this.id,
    required this.proveedorId,
    required this.codigoCotizacion,
    required this.fechaEmision,
    required this.fechaValidez,
    required this.totalPropuesto,
    required this.detalles,
  });

  bool get vencida => DateTime.now().isAfter(fechaValidez);

  factory Cotizacion.fromJson(Map<String, dynamic> json) => Cotizacion(
        id:               json['id'] as int,
        proveedorId:      json['proveedor'] as int,
        codigoCotizacion: json['codigo_cotizacion'] as String,
        fechaEmision:     DateTime.parse(json['fecha_emision'] as String),
        fechaValidez:     DateTime.parse(json['fecha_validez'] as String),
        totalPropuesto:   double.parse(json['total_propuesto'].toString()),
        detalles: (json['detalles'] as List<dynamic>? ?? [])
            .map((d) => CotizacionDetalle.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}