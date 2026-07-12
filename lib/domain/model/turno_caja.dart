// lib/domain/model/turno_caja.dart

enum EstadoTurno { abierto, cerrado }

EstadoTurno estadoTurnoFromString(String value) => switch (value) {
      'ABIERTO' => EstadoTurno.abierto,
      'CERRADO' => EstadoTurno.cerrado,
      _         => EstadoTurno.cerrado,
    };

String estadoTurnoToString(EstadoTurno estado) => switch (estado) {
      EstadoTurno.abierto => 'ABIERTO',
      EstadoTurno.cerrado => 'CERRADO',
    };

class TurnoCaja {
  final int          id;
  final int          cajeroId;
  final String       nombreCajero;
  final DateTime     fechaApertura;
  final DateTime?    fechaCierre;
  final double       montoApertura;
  final double?      montoCierre;
  final EstadoTurno  estado;
  final String       observaciones;

  const TurnoCaja({
    required this.id,
    required this.cajeroId,
    required this.nombreCajero,
    required this.fechaApertura,
    required this.montoApertura,
    required this.estado,
    this.fechaCierre,
    this.montoCierre,
    this.observaciones = '',
  });

  bool get estaAbierto => estado == EstadoTurno.abierto;

  factory TurnoCaja.fromJson(Map<String, dynamic> json) => TurnoCaja(
        id:            json['id'] as int,
        cajeroId:      json['cajero'] as int,
        nombreCajero:  json['nombre_cajero'] as String? ?? '',
        fechaApertura: DateTime.parse(json['fecha_apertura'] as String),
        fechaCierre:   json['fecha_cierre'] != null
            ? DateTime.parse(json['fecha_cierre'] as String)
            : null,
        montoApertura: double.parse(json['monto_apertura'].toString()),
        montoCierre:   json['monto_cierre'] != null
            ? double.parse(json['monto_cierre'].toString())
            : null,
        estado:        estadoTurnoFromString(json['estado'] as String),
        observaciones: json['observaciones'] as String? ?? '',
      );

  TurnoCaja copyWith({
    int?         id,
    int?         cajeroId,
    String?      nombreCajero,
    DateTime?    fechaApertura,
    DateTime?    fechaCierre,
    double?      montoApertura,
    double?      montoCierre,
    EstadoTurno? estado,
    String?      observaciones,
  }) => TurnoCaja(
        id:            id            ?? this.id,
        cajeroId:      cajeroId      ?? this.cajeroId,
        nombreCajero:  nombreCajero  ?? this.nombreCajero,
        fechaApertura: fechaApertura ?? this.fechaApertura,
        fechaCierre:   fechaCierre   ?? this.fechaCierre,
        montoApertura: montoApertura ?? this.montoApertura,
        montoCierre:   montoCierre   ?? this.montoCierre,
        estado:        estado        ?? this.estado,
        observaciones: observaciones ?? this.observaciones,
      );
}