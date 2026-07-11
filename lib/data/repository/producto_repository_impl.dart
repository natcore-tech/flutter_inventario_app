import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/producto_repository.dart';
import '../remote/api/product_remote_datasource.dart';

class ProductoRepositoryImpl implements ProductoRepository {
    final ProductoRemoteDataSource remoteDataSource;

    ProductoRepositoryImpl(this.remoteDataSource);

    @override
    Future<List<Producto>> getProductos({String? categoriaId, String? marcaId}) => 
        remoteDataSource.getProductos(categoriaId: categoriaId, marcaId: marcaId);

    @override
    Future<Producto?> getProductoById(String id) => remoteDataSource.getProductoById(id);

    @override
    Future<Producto> createProducto(Producto producto) => remoteDataSource.createProducto(producto);

    @override
    Future<Producto> updateProducto(Producto producto) => remoteDataSource.updateProducto(producto);

    @override
    Future<void> deleteProducto(String id) => remoteDataSource.deleteProducto(id);
}

final productoRepositoryProvider = Provider<ProductoRepository>((ref) {
    final dataSource = ref.watch(productoRemoteDataSourceProvider);
    return ProductoRepositoryImpl(dataSource);
});