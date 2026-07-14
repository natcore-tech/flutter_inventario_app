// lib/data/remote/api/categoria_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../domain/model/categoria.dart';
import '../../../core/error/api_exception.dart';

class CategoriaRemoteDataSource {
  final Dio _dio;

  CategoriaRemoteDataSource(this._dio);

  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await _dio.get('/categorias/');
      
      // Manejar la paginación (StandardPagination)
      List<dynamic> data;
      if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
        data = response.data['results'];
      } else {
        data = response.data as List; // Fallback por si en algún momento se quita la paginación
      }

      return data.map((json) => Categoria.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Categoria> createCategoria(Categoria categoria) async {
    try {
      final response = await _dio.post(
        '/categorias/',
        data: categoria.toJson(),
      );
      return Categoria.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Categoria> updateCategoria(Categoria categoria) async {
    try {
      final response = await _dio.put(
        '/categorias/${categoria.id}/',
        data: categoria.toJson(),
      );
      return Categoria.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteCategoria(int id) async {
    try {
      await _dio.delete('/categorias/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}