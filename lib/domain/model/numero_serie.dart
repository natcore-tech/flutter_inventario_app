class NumeroSerie {
  final int? id;
  final int productoId;
  final String codigoSerial;
  final String estado;
  final DateTime? fechaIngreso;

  NumeroSerie({
    this.id,
    required this.productoId,
    required this.codigoSerial,
    this.estado = 'DISPONIBLE',
    this.fechaIngreso,
  });

  factory NumeroSerie.fromJson(Map<String, dynamic> json) {
    return NumeroSerie(
      id: json['id'],
      productoId: json['producto'],
      codigoSerial: json['codigo_serial'] ?? '',
      estado: json['estado'] ?? 'DISPONIBLE',
      fechaIngreso: json['fecha_ingreso'] != null 
          ? DateTime.parse(json['fecha_ingreso']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto': productoId,
      'codigo_serial': codigoSerial,
      'estado': estado,
    };
  }
}