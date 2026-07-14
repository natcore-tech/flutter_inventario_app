// lib/data/remote/api/marca_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../domain/model/marca.dart';
import '../../../core/error/api_exception.dart';

class MarcaRemoteDataSource {
  final Dio _dio;

  MarcaRemoteDataSource(this._dio);

  Future<List<Marca>> getMarcas() async {
    try {
      final response = await _dio.get('/marcas/');
      final data = response.data as List;
      return data.map((json) => Marca.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Marca> createMarca(Marca marca) async {
    try {
      final response = await _dio.post(
        '/marcas/',
        data: marca.toJson(),
      );
      return Marca.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Marca> updateMarca(Marca marca) async {
    try {
      final response = await _dio.put(
        '/marcas/${marca.id}/',
        data: marca.toJson(),
      );
      return Marca.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteMarca(int id) async {
    try {
      await _dio.delete('/marcas/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}