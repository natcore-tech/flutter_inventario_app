class AlertaStockMinimo {
  final String id;
  final String productoId;
  final int cantidadMinima;
  final String emailNotificacion;
  final bool activa;

  AlertaStockMinimo({
    required this.id,
    required this.productoId,
    required this.cantidadMinima,
    required this.emailNotificacion,
    this.activa = true,
  });

  AlertaStockMinimo copyWith({String? id, String? productoId, int? cantidadMinima, String? emailNotificacion, bool? activa}) {
    return AlertaStockMinimo(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      cantidadMinima: cantidadMinima ?? this.cantidadMinima,
      emailNotificacion: emailNotificacion ?? this.emailNotificacion,
      activa: activa ?? this.activa,
    );
  }

  factory AlertaStockMinimo.fromJson(Map<String, dynamic> json) {
    return AlertaStockMinimo(
      id: json['id']?.toString() ?? '',
      productoId: json['producto']?.toString() ?? '',
      cantidadMinima: json['cantidad_minima'] ?? 5,
      emailNotificacion: json['email_notificacion'] ?? '',
      activa: json['activa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'producto': productoId,
    'cantidad_minima': cantidadMinima,
    'email_notificacion': emailNotificacion,
    'activa': activa,
  };
}