// lib/domain/model/unidad_medida.dart

class UnidadMedida {
  final int? id;
  final String nombre;
  final String abreviatura;
  final String? descripcionCompleta;

  UnidadMedida({
    this.id,
    required this.nombre,
    required this.abreviatura,
    this.descripcionCompleta,
  });

  factory UnidadMedida.fromJson(Map<String, dynamic> json) {
    return UnidadMedida(
      id: json['id'],
      nombre: json['nombre'],
      abreviatura: json['abreviatura'],
      descripcionCompleta: json['descripcion_completa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'abreviatura': abreviatura,
      // 'descripcion_completa' es read_only
    };
  }
}