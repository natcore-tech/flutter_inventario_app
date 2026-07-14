// lib/data/remote/api/producto_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../domain/model/producto.dart';
import '../../../core/error/api_exception.dart';

class ProductoRemoteDataSource {
  final Dio _dio;

  ProductoRemoteDataSource(this._dio);

  Future<List<Producto>> getProductos() async {
    try {
      final response = await _dio.get('/productos/');
      
      List<dynamic> data;
      if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
        data = response.data['results'];
      } else {
        data = response.data as List;
      }

      return data.map((json) => Producto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Producto> createProducto(Producto producto) async {
    try {
      final response = await _dio.post(
        '/productos/',
        data: producto.toJson(),
      );
      return Producto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Producto> updateProducto(Producto producto) async {
    try {
      final response = await _dio.put(
        '/productos/${producto.id}/',
        data: producto.toJson(),
      );
      return Producto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteProducto(int id) async {
    try {
      await _dio.delete('/productos/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Endpoint personalizado @action
  Future<void> reabastecerProducto(int id, int cantidad) async {
    try {
      await _dio.post(
        '/productos/$id/reabastecer/',
        data: {'quantity': cantidad},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Método para el catálogo público
  Future<List<Producto>> getProductosDisponibles() async {
    try {
      final response = await _dio.get('/productos/disponibles/');
      
      List<dynamic> data;
      if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
        data = response.data['results'];
      } else {
        data = response.data as List;
      }

      return data.map((json) => Producto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
  
}