// lib/domain/model/producto.dart

import 'categoria.dart';

class Producto {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final double? precioConImpuesto;
  final int stock;
  final bool? enStock;
  final bool esActivo;
  final int categoriaId;
  final Categoria? categoria; // Objeto anidado que viene del GET

  Producto({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.precioConImpuesto,
    required this.stock,
    this.enStock,
    this.esActivo = true,
    required this.categoriaId,
    this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    // Extraemos el objeto categoría si viene en la respuesta
    final catObj = json['categoria'] != null ? Categoria.fromJson(json['categoria']) : null;
    
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      precioConImpuesto: json['precio_con_impuesto'] != null 
          ? double.tryParse(json['precio_con_impuesto'].toString()) 
          : null,
      stock: json['stock'] ?? 0,
      enStock: json['en_stock'],
      esActivo: json['es_activo'] ?? true,
      categoriaId: json['categoria_id'] ?? catObj?.id ?? 0,
      categoria: catObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion ?? '',
      'precio': precio.toString(),
      'stock': stock,
      'es_activo': esActivo,
      'categoria_id': categoriaId, // Django espera 'categoria_id' para escritura
    };
  }
}