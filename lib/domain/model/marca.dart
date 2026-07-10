class Marca {
    final String id;
    final String nombre;
    final String? descripcion;
    final bool activo;

Marca({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.activo = true,
});

Marca copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    bool? activo,
}) {
        return Marca(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        activo: activo ?? this.activo,
        );
    }
}