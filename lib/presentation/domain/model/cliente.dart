// lib/domain/model/cliente.dart

class Cliente {
  final int id;
  final String identificacion;
  final String nombres;
  final String? email;
  final String telefono;
  final String direccion;
  final bool esActivo;
  final DateTime? creadoEn;

  Cliente({
    required this.id,
    required this.identificacion,
    required this.nombres,
    this.email,
    required this.telefono,
    required this.direccion,
    required this.esActivo,
    this.creadoEn,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: json["id"],
        identificacion: json["identificacion"] ?? '',
        nombres: json["nombres"] ?? '',
        email: json["email"],
        telefono: json["telefono"] ?? '',
        direccion: json["direccion"] ?? '',
        esActivo: json["es_activo"] ?? true,
        creadoEn: json["creado_en"] != null 
            ? DateTime.parse(json["creado_en"]) 
            : null,
      );

  Map<String, dynamic> toJson() => {
        "identificacion": identificacion,
        "nombres": nombres,
        "email": email,
        "telefono": telefono,
        "direccion": direccion,
        "es_activo": esActivo,
      };

  // Método copyWith para mantener la inmutabilidad
  Cliente copyWith({
    int? id,
    String? identificacion,
    String? nombres,
    String? email,
    String? telefono,
    String? direccion,
    bool? esActivo,
  }) =>
      Cliente(
        id: id ?? this.id,
        identificacion: identificacion ?? this.identificacion,
        nombres: nombres ?? this.nombres,
        email: email ?? this.email,
        telefono: telefono ?? this.telefono,
        direccion: direccion ?? this.direccion,
        esActivo: esActivo ?? this.esActivo,
      );
}