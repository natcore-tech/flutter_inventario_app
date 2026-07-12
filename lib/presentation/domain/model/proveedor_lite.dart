// lib/presentation/domain/model/proveedor_lite.dart
//
// Modelo de SOLO LECTURA para elegir proveedor al crear una cotización.
// El CRUD completo de Proveedor es de Elihú (feature/compras-proveedores).

class ProveedorLite {
  final int    id;
  final String nombre;
  final String ruc;
  final bool   esActivo;

  const ProveedorLite({
    required this.id,
    required this.nombre,
    required this.ruc,
    required this.esActivo,
  });

  factory ProveedorLite.fromJson(Map<String, dynamic> json) => ProveedorLite(
        id:       json['id'] as int,
        nombre:   json['nombre'] as String,
        ruc:      json['ruc'] as String? ?? '',
        esActivo: json['es_activo'] as bool? ?? true,
      );
}