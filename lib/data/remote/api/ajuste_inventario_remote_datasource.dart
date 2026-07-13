// lib/data/remote/api/ajuste_inventario_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../domain/model/ajuste_inventario.dart';
import '../../../core/error/api_exception.dart';

class AjusteInventarioRemoteDataSource {
  final Dio _dio;

  AjusteInventarioRemoteDataSource(this._dio);

  Future<List<AjusteInventario>> getAjustes() async {
    try {
      // Apunta a router.register('ajustes-inventario', ...)
      final response = await _dio.get('/ajustes-inventario/');
      final data = response.data as List;
      return data.map((json) => AjusteInventario.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AjusteInventario> createAjuste(AjusteInventario ajuste) async {
    try {
      final response = await _dio.post(
        '/ajustes-inventario/',
        data: ajuste.toJson(),
      );
      return AjusteInventario.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AjusteInventario> updateAjuste(AjusteInventario ajuste) async {
    try {
      final response = await _dio.put(
        '/ajustes-inventario/${ajuste.id}/',
        data: ajuste.toJson(),
      );
      return AjusteInventario.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteAjuste(int id) async {
    try {
      await _dio.delete('/ajustes-inventario/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}