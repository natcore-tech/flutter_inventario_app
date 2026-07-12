class UbicacionFisica {
  final String id;
  final String pasillo;
  final String estante;
  final String? coordenadaExacta; 

  UbicacionFisica({
    required this.id,
    required this.pasillo,
    required this.estante,
    this.coordenadaExacta,
  });

  UbicacionFisica copyWith({String? id, String? pasillo, String? estante, String? coordenadaExacta}) {
    return UbicacionFisica(
      id: id ?? this.id,
      pasillo: pasillo ?? this.pasillo,
      estante: estante ?? this.estante,
      coordenadaExacta: coordenadaExacta ?? this.coordenadaExacta,
    );
  }

  factory UbicacionFisica.fromJson(Map<String, dynamic> json) {
    return UbicacionFisica(
      id: json['id']?.toString() ?? '',
      pasillo: json['pasillo'] ?? '',
      estante: json['estante'] ?? '',
      coordenadaExacta: json['coordenada_exacta'],
    );
  }

  Map<String, dynamic> toJson() => {
    'pasillo': pasillo,
    'estante': estante,
  };
}