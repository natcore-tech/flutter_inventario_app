// lib/data/remote/api/traslado_bodega_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../domain/model/traslado_bodega.dart';
import '../../../core/error/api_exception.dart';

class TrasladoBodegaRemoteDataSource {
  final Dio _dio;

  TrasladoBodegaRemoteDataSource(this._dio);

  Future<List<TrasladoBodega>> getTraslados() async {
    try {
      final response = await _dio.get('/traslados-bodegas/');
      final data = response.data as List;
      return data.map((json) => TrasladoBodega.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<TrasladoBodega> createTraslado(TrasladoBodega traslado) async {
    try {
      final response = await _dio.post(
        '/traslados-bodegas/',
        data: traslado.toJson(),
      );
      return TrasladoBodega.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> completarTraslado(int id) async {
    try {
      await _dio.post('/traslados-bodegas/$id/completar/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}