// lib/data/remote/api/unidad_medida_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../domain/model/unidad_medida.dart';
import '../../../core/error/api_exception.dart';

class UnidadMedidaRemoteDataSource {
  final Dio _dio;

  UnidadMedidaRemoteDataSource(this._dio);

  Future<List<UnidadMedida>> getUnidades() async {
    try {
      final response = await _dio.get('/unidades-medida/');
      
      // Manejamos posible paginación global o listado directo
      List<dynamic> data;
      if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
        data = response.data['results'];
      } else {
        data = response.data as List;
      }

      return data.map((json) => UnidadMedida.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UnidadMedida> createUnidad(UnidadMedida unidad) async {
    try {
      final response = await _dio.post(
        '/unidades-medida/',
        data: unidad.toJson(),
      );
      return UnidadMedida.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UnidadMedida> updateUnidad(UnidadMedida unidad) async {
    try {
      final response = await _dio.put(
        '/unidades-medida/${unidad.id}/',
        data: unidad.toJson(),
      );
      return UnidadMedida.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteUnidad(int id) async {
    try {
      await _dio.delete('/unidades-medida/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}