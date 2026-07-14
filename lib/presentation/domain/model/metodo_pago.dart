// lib/presentation/domain/model/metodo_pago.dart

class MetodoPago {
  final int    id;
  final String nombre;
  final bool   esActivo;

  const MetodoPago({
    required this.id,
    required this.nombre,
    required this.esActivo,
  });

  factory MetodoPago.fromJson(Map<String, dynamic> json) => MetodoPago(
        id:       json['id'] as int,
        nombre:   json['nombre'] as String,
        esActivo: json['es_activo'] as bool? ?? true,
      );
}