class Proveedor {
  final int? id;
  final String nombre;
  final String ruc;
  final String telefono;
  final String email;
  final String direccion;
  final bool esActivo;
  final DateTime? creadoEn;

  Proveedor({
    this.id,
    required this.nombre,
    required this.ruc,
    this.telefono = '',
    this.email = '',
    this.direccion = '',
    this.esActivo = true,
    this.creadoEn,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      ruc: json['ruc'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      direccion: json['direccion'] ?? '',
      esActivo: json['es_activo'] ?? true,
      creadoEn: json['creado_en'] != null 
          ? DateTime.parse(json['creado_en']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'ruc': ruc,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'es_activo': esActivo,
    };
  }
}