// lib/domain/model/product.dart

class ProductCategory {
  final int    id;
  final String name;
  const ProductCategory({required this.id, required this.name});

  factory ProductCategory.fromJson(Map<String, dynamic> j) =>
      ProductCategory(id: j['id'] as int, name: j['name'] as String);
}

class Product {
  final int              id;
  final String           name;
  final String           description;
  final double           price;
  final double           priceWithTax;
  final int              stock;
  final bool             inStock;
  final bool             isActive;
  final String?          imageUrl;       // <-- URL absoluta o null
  final ProductCategory? category;
  final String           createdAt;
  final String           updatedAt;

  // CORREGIDO: Reemplazados los '...' por la inicialización real de las variables obligatorias
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceWithTax,
    required this.stock,
    required this.inStock,
    required this.isActive,
    this.imageUrl,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id:           j['id']                                  as int,
    name:         j['name']                                as String,
    description:  j['description']                         as String,
    price:        double.parse(j['price'].toString()),
    priceWithTax: (j['price_with_tax'] as num).toDouble(),
    stock:        j['stock']                               as int,
    inStock:      j['in_stock']                            as bool,
    isActive:     j['is_active']                           as bool,
    imageUrl:     j['image_url']                           as String?,
    category:     j['category'] != null
                  ? ProductCategory.fromJson(j['category'] as Map<String, dynamic>)
                  : null,
    createdAt:    j['created_at']                          as String,
    updatedAt:    j['updated_at']                          as String,
  );

  /// Placeholder usado cuando el producto no se encuentra en el catálogo.
  static Product empty() => const Product(
    id: 0, name: '', description: '', price: 0.0, priceWithTax: 0.0,
    stock: 0, inStock: false, isActive: false, imageUrl: null, category: null,
    createdAt: '', updatedAt: '',
  );

  // CORREGIDO: Ahora el método copyWith retorna el objeto modificado de forma correcta
  Product copyWith({required int stock, required bool isActive}) {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      priceWithTax: priceWithTax,
      stock: stock,
      inStock: stock > 0,
      isActive: isActive,
      imageUrl: imageUrl,
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}