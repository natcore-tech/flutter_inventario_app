// lib/domain/model/traslado_bodega.dart

class TrasladoBodegaDetalle {
  final int? id;
  final int? trasladoId;
  final int productoId;
  final int cantidad;

  TrasladoBodegaDetalle({
    this.id,
    this.trasladoId,
    required this.productoId,
    required this.cantidad,
  });

  factory TrasladoBodegaDetalle.fromJson(Map<String, dynamic> json) {
    return TrasladoBodegaDetalle(
      id: json['id'],
      trasladoId: json['traslado'],
      productoId: json['producto'],
      cantidad: json['cantidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto': productoId,
      'cantidad': cantidad,
    };
  }
}

class TrasladoBodega {
  final int? id;
  final DateTime? fechaTraslado;
  final int bodegaOrigenId;
  final String? bodegaOrigenNombre;
  final int bodegaDestinoId;
  final String? bodegaDestinoNombre;
  final String estado; // 'EN_TRANSITO', 'COMPLETADO', 'CANCELADO'
  final List<TrasladoBodegaDetalle> detalles;

  TrasladoBodega({
    this.id,
    this.fechaTraslado,
    required this.bodegaOrigenId,
    this.bodegaOrigenNombre,
    required this.bodegaDestinoId,
    this.bodegaDestinoNombre,
    this.estado = 'EN_TRANSITO',
    required this.detalles,
  });

  factory TrasladoBodega.fromJson(Map<String, dynamic> json) {
    return TrasladoBodega(
      id: json['id'],
      fechaTraslado: json['fecha_traslado'] != null ? DateTime.parse(json['fecha_traslado']) : null,
      bodegaOrigenId: json['bodega_origen'],
      bodegaOrigenNombre: json['bodega_origen_nombre'],
      bodegaDestinoId: json['bodega_destino'],
      bodegaDestinoNombre: json['bodega_destino_nombre'],
      estado: json['estado'] ?? 'EN_TRANSITO',
      detalles: json['detalles'] != null 
          ? (json['detalles'] as List).map((i) => TrasladoBodegaDetalle.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bodega_origen': bodegaOrigenId,
      'bodega_destino': bodegaDestinoId,
      'detalles': detalles.map((d) => d.toJson()).toList(),
    };
  }
}