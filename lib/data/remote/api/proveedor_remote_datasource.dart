import 'package:dio/dio.dart';
import '../../../domain/model/proveedor.dart';
import '../../../core/error/api_exception.dart';

class ProveedorRemoteDataSource {
  final Dio _dio;

  ProveedorRemoteDataSource(this._dio);

  Future<List<Proveedor>> getProveedores() async {
    try {
      final response = await _dio.get('/proveedores/'); 
      
      final data = response.data;
      final List<dynamic> results = data is Map ? data['results'] : data;
      
      return results.map((json) => Proveedor.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Proveedor> getProveedorById(int id) async {
    try {
      final response = await _dio.get('/proveedores/$id/');
      return Proveedor.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Proveedor> createProveedor(Proveedor proveedor) async {
    try {
      final response = await _dio.post(
        '/proveedores/',
        data: proveedor.toJson(),
      );
      return Proveedor.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Proveedor> updateProveedor(Proveedor proveedor) async {
    try {
      final response = await _dio.put(
        '/proveedores/${proveedor.id}/',
        data: proveedor.toJson(),
      );
      return Proveedor.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteProveedor(int id) async {
    try {
      await _dio.delete('/proveedores/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}