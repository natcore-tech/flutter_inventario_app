class Categoria {
    final String id;
    final String nombre;
    final String? descripcion;
    final bool activo;

Categoria({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.activo = true,
});

Categoria copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    bool? activo,
}) {
        return Categoria(
            id: id ?? this.id,
            nombre: nombre ?? this.nombre,
            descripcion: descripcion ?? this.descripcion,
            activo: activo ?? this.activo,
            );
        }
}

factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
        id: json['id'] ?? json['_id'] ?? '',
        nombre: json['nombre'] ?? '',
        descripcion: json['descripcion'],
        activo: json['activo'] ?? true,
    );
}

Map<String, dynamic> toJson() {
    return {
        'nombre': nombre,
        'descripcion': descripcion,
        'activo': activo,
    };
}