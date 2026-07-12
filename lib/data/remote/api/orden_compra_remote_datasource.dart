import 'package:dio/dio.dart';
import '../../../domain/model/orden_compra.dart';
import '../../../core/error/api_exception.dart';

class OrdenCompraRemoteDataSource {
  final Dio _dio;

  OrdenCompraRemoteDataSource(this._dio);

  Future<List<OrdenCompra>> getOrdenesCompra() async {
    try {
      final response = await _dio.get('/ordenes-compra/'); 
      
      final data = response.data;
      final List<dynamic> results = data is Map ? data['results'] : data;
      
      return results.map((json) => OrdenCompra.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrdenCompra> getOrdenCompraById(int id) async {
    try {
      final response = await _dio.get('/ordenes_compra/$id/');
      return OrdenCompra.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrdenCompra> createOrdenCompra(OrdenCompra orden) async {
    try {
      final response = await _dio.post(
        '/ordenes_compra/',
        data: orden.toJson(),
      );
      return OrdenCompra.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrdenCompra> updateOrdenCompra(OrdenCompra orden) async {
    try {
      final response = await _dio.patch(
        '/ordenes_compra/${orden.id}/',
        data: {'estado': orden.estado}, 
      );
      return OrdenCompra.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteOrdenCompra(int id) async {
    try {
      await _dio.delete('/ordenes_compra/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}