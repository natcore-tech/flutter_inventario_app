import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/product.dart';
import '../../data/repository/producto_repository_impl.dart';

class ProductsAdminNotifier extends AsyncNotifier<List<Producto>> {
  @override
  Future<List<Producto>> build() async {
    return _fetchProducts();
  }

  Future<List<Producto>> _fetchProducts({String? categoriaId, String? marcaId}) async {
    final repository = ref.read(productoRepositoryProvider);
    return await repository.getProductos(categoriaId: categoriaId, marcaId: marcaId);
  }

  // Permite a la UI filtrar productos por categoría o marca
  Future<void> filterProducts({String? categoriaId, String? marcaId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _fetchProducts(categoriaId: categoriaId, marcaId: marcaId);
    });
  }

  Future<void> addProduct(Producto producto) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productoRepositoryProvider);
      await repository.createProducto(producto);
      return _fetchProducts();
    });
  }

  Future<void> updateProduct(Producto producto) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productoRepositoryProvider);
      await repository.updateProducto(producto);
      return _fetchProducts();
    });
  }

  Future<void> deleteProduct(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productoRepositoryProvider);
      await repository.deleteProducto(id);
      return _fetchProducts();
    });
  }
}

final productsAdminProvider = AsyncNotifierProvider<ProductsAdminNotifier, List<Producto>>(() {
  return ProductsAdminNotifier();
});