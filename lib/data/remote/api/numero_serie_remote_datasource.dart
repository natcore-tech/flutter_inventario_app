import 'package:dio/dio.dart';
import '../../../domain/model/numero_serie.dart';
import '../../../core/error/api_exception.dart';

class NumeroSerieRemoteDataSource {
  final Dio _dio;

  NumeroSerieRemoteDataSource(this._dio);

  Future<List<NumeroSerie>> getNumerosSerie({int? productoId}) async {
    try {
      final queryParams = productoId != null ? {'producto': productoId} : null;
      
      final response = await _dio.get(
        '/numeros-serie/', 
        queryParameters: queryParams,
      ); 
      
      final data = response.data;
      final List<dynamic> results = data is Map ? data['results'] : data;
      
      return results.map((json) => NumeroSerie.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<NumeroSerie> getNumeroSerieById(int id) async {
    try {
      final response = await _dio.get('/numeros-serie/$id/');
      return NumeroSerie.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<NumeroSerie> createNumeroSerie(NumeroSerie numeroSerie) async {
    try {
      final response = await _dio.post(
        '/numeros-serie/',
        data: numeroSerie.toJson(),
      );
      return NumeroSerie.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // 4. Actualizar un número de serie (ej. cambiar estado de DISPONIBLE a VENDIDO)
  Future<NumeroSerie> updateNumeroSerie(NumeroSerie numeroSerie) async {
    try {
      final response = await _dio.put(
        '/numeros-serie/${numeroSerie.id}/',
        data: numeroSerie.toJson(),
      );
      return NumeroSerie.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // 5. Eliminar un número de serie (si se registró por error)
  Future<void> deleteNumeroSerie(int id) async {
    try {
      await _dio.delete('/numeros-serie/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}