// lib/presentation/domain/model/devolucion_cliente.dart

enum EstadoProductoDevuelto { bueno, danio, usado }

EstadoProductoDevuelto estadoProductoFromString(String v) => switch (v) {
      'BUENO' => EstadoProductoDevuelto.bueno,
      'DANO'  => EstadoProductoDevuelto.danio,
      'USADO' => EstadoProductoDevuelto.usado,
      _       => EstadoProductoDevuelto.bueno,
    };

String estadoProductoToString(EstadoProductoDevuelto e) => switch (e) {
      EstadoProductoDevuelto.bueno => 'BUENO',
      EstadoProductoDevuelto.danio => 'DANO',
      EstadoProductoDevuelto.usado => 'USADO',
    };

String estadoProductoLabel(EstadoProductoDevuelto e) => switch (e) {
      EstadoProductoDevuelto.bueno => 'Buen estado',
      EstadoProductoDevuelto.danio => 'Dañado',
      EstadoProductoDevuelto.usado => 'Usado',
    };

class DevolucionCliente {
  final int    id;
  final int    productoId;
  final DateTime fechaDevolucion;
  final String motivo;
  final int    cantidad;
  final EstadoProductoDevuelto estadoProducto;

  const DevolucionCliente({
    required this.id,
    required this.productoId,
    required this.fechaDevolucion,
    required this.motivo,
    required this.cantidad,
    required this.estadoProducto,
  });


  bool get reingresaStock => estadoProducto == EstadoProductoDevuelto.bueno;

  factory DevolucionCliente.fromJson(Map<String, dynamic> json) => DevolucionCliente(
        id:              json['id'] as int,
        productoId:      json['producto'] as int,
        fechaDevolucion: DateTime.parse(json['fecha_devolucion'] as String),
        motivo:          json['motivo'] as String,
        cantidad:        json['cantidad'] as int,
        estadoProducto:  estadoProductoFromString(json['estado_producto'] as String),
      );
}