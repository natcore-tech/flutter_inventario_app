import '../model/product.dart';

abstract class ProductoRepository {
    Future<List<Producto>> getProductos({String? categoriaId, String? marcaId});
    Future<Producto?> getProductoById(String id);
    Future<Producto> createProducto(Producto producto);
    Future<Producto> updateProducto(Producto producto);
    Future<void> deleteProducto(String id);
}