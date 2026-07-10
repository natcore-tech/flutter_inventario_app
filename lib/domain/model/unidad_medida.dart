class UnidadMedida {
    final String id;
    final String nombre;
    final String abreviatura; // Ej: 'kg', 'L', 'u'

UnidadMedida({
    required this.id,
    required this.nombre,
    required this.abreviatura,
});

UnidadMedida copyWith({
    String? id,
    String? nombre,
    String? abreviatura,
}) {
        return UnidadMedida(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        abreviatura: abreviatura ?? this.abreviatura,
        );
    }
}