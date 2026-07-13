// lib/domain/model/ajuste_inventario.dart

class AjusteInventario {
  final int? id;
  final int productoId;
  final String tipoAjuste; // 'ROBO', 'DANO', 'CADUCIDAD', 'ERROR'
  final int cantidad;
  final String justificativo;
  final DateTime? creadoEn;

  AjusteInventario({
    this.id,
    required this.productoId,
    required this.tipoAjuste,
    required this.cantidad,
    required this.justificativo,
    this.creadoEn,
  });

  factory AjusteInventario.fromJson(Map<String, dynamic> json) {
    return AjusteInventario(
      id: json['id'],
      productoId: json['producto'],
      tipoAjuste: json['tipo_ajuste'],
      cantidad: json['cantidad'],
      justificativo: json['justificativo'],
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto': productoId,
      'tipo_ajuste': tipoAjuste,
      'cantidad': cantidad,
      'justificativo': justificativo,
    };
  }
}