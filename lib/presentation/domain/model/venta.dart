// lib/presentation/domain/model/venta.dart

class VentaDetalle {
  final int?    id; // null antes de crear
  final int     productoId;
  final String  nombreProducto;
  final int     cantidad;
  final double? precioUnitarioVenta; // lo calcula el backend
  final double? subtotalLinea;       // lo calcula el backend

  const VentaDetalle({
    this.id,
    required this.productoId,
    this.nombreProducto = '',
    required this.cantidad,
    this.precioUnitarioVenta,
    this.subtotalLinea,
  });

  factory VentaDetalle.fromJson(Map<String, dynamic> json) => VentaDetalle(
        id:                  json['id'] as int?,
        productoId:          json['producto'] as int,
        nombreProducto:      json['nombre_producto'] as String? ?? '',
        cantidad:            json['cantidad'] as int,
        precioUnitarioVenta: json['precio_unitario_venta'] != null
            ? double.parse(json['precio_unitario_venta'].toString())
            : null,
        subtotalLinea: json['subtotal_linea'] != null
            ? double.parse(json['subtotal_linea'].toString())
            : null,
      );

  /// El backend solo necesita producto + cantidad; el resto lo calcula él.
  Map<String, dynamic> toPayload() => {
        'producto': productoId,
        'cantidad': cantidad,
      };
}

class PagoVenta {
  final int?    id;
  final int     metodoPagoId;
  final String  nombreMetodo;
  final double  monto;
  final DateTime? fechaPago;

  const PagoVenta({
    this.id,
    required this.metodoPagoId,
    this.nombreMetodo = '',
    required this.monto,
    this.fechaPago,
  });

  factory PagoVenta.fromJson(Map<String, dynamic> json) => PagoVenta(
        id:           json['id'] as int?,
        metodoPagoId: json['metodo_pago'] as int,
        nombreMetodo: json['nombre_metodo'] as String? ?? '',
        monto:        double.parse(json['monto'].toString()),
        fechaPago:    json['fecha_pago'] != null
            ? DateTime.parse(json['fecha_pago'] as String)
            : null,
      );

  Map<String, dynamic> toPayload() => {
        'metodo_pago': metodoPagoId,
        'monto':       monto,
      };
}

enum EstadoVenta { emitida, pagada, anulada }

EstadoVenta estadoVentaFromString(String v) => switch (v) {
      'EMITIDA' => EstadoVenta.emitida,
      'PAGADA'  => EstadoVenta.pagada,
      'ANULADA' => EstadoVenta.anulada,
      _         => EstadoVenta.emitida,
    };

class Venta {
  final int             id;
  final int             clienteId;
  final String          nombreCliente;
  final String          nombreCajero;
  final int             turnoId;
  final DateTime        fechaEmision;
  final double          subtotal;
  final double          iva;
  final double          total;
  final EstadoVenta      estado;
  final List<VentaDetalle> detalles;
  final List<PagoVenta>    pagos;

  const Venta({
    required this.id,
    required this.clienteId,
    required this.nombreCliente,
    required this.nombreCajero,
    required this.turnoId,
    required this.fechaEmision,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.estado,
    required this.detalles,
    required this.pagos,
  });

  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
        id:            json['id'] as int,
        clienteId:     json['cliente'] as int,
        nombreCliente: json['nombre_cliente'] as String? ?? '',
        nombreCajero:  json['nombre_cajero'] as String? ?? '',
        turnoId:       json['turno'] as int,
        fechaEmision:  DateTime.parse(json['fecha_emision'] as String),
        subtotal:      double.parse(json['subtotal'].toString()),
        iva:           double.parse(json['iva'].toString()),
        total:         double.parse(json['total'].toString()),
        estado:        estadoVentaFromString(json['estado'] as String),
        detalles: (json['detalles'] as List<dynamic>? ?? [])
            .map((d) => VentaDetalle.fromJson(d as Map<String, dynamic>))
            .toList(),
        pagos: (json['pagos'] as List<dynamic>? ?? [])
            .map((p) => PagoVenta.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}