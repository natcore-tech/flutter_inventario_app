class Promocion {
    final String id;
    final String productoId;
    final double porcentajeDescuento;
    final DateTime fechaInicio;
    final DateTime fechaFin;
    final bool activa;

Promocion({
    required this.id,
    required this.productoId,
    required this.porcentajeDescuento,
    required this.fechaInicio,
    required this.fechaFin,
    this.activa = true,
});

Promocion copyWith({
    String? id,
    String? productoId,
    double? porcentajeDescuento,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? activa,
}) {
    return Promocion(
        id: id ?? this.id,
        productoId: productoId ?? this.productoId,
        porcentajeDescuento: porcentajeDescuento ?? this.porcentajeDescuento,
        fechaInicio: fechaInicio ?? this.fechaInicio,
        fechaFin: fechaFin ?? this.fechaFin,
        activa: activa ?? this.activa,
    );
}
}