import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import 'dio_client.dart';
import '../../../domain/model/product.dart';

class ProductoRemoteDataSource {
  final Dio dio;

  ProductoRemoteDataSource(this.dio);

  Future<List<Producto>> getProductos({String? categoriaId, String? marcaId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoriaId != null) queryParams['categoria'] = categoriaId;
      if (marcaId != null) queryParams['marca'] = marcaId;

      final response = await dio.get('/api/productos/', queryParameters: queryParams);
      return (response.data as List).map((json) => Producto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException('Error al obtener productos: ${e.message}');
    }
  }

  Future<Producto> getProductoById(String id) async {
    try {
      final response = await dio.get('/api/productos/$id/');
      return Producto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Error al obtener producto: ${e.message}');
    }
  }

  Future<Producto> createProducto(Producto producto) async {
    try {
      final response = await dio.post('/api/productos/', data: producto.toJson());
      return Producto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Error al crear producto: ${e.message}');
    }
  }

  Future<Producto> updateProducto(Producto producto) async {
    try {
      final response = await dio.put('/api/productos/${producto.id}/', data: producto.toJson());
      return Producto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Error al actualizar producto: ${e.message}');
    }
  }

  Future<void> deleteProducto(String id) async {
    try {
      await dio.delete('/api/productos/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar producto: ${e.message}');
    }
  }
}

final productoRemoteDataSourceProvider = Provider<ProductoRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductoRemoteDataSource(dio);
});