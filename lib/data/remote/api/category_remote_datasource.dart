import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import 'dio_client.dart';
import '../../../domain/model/category.dart';

class CategoriaRemoteDataSource {
  final Dio dio;

  CategoriaRemoteDataSource(this.dio);

  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await dio.get('/api/categorias/');
      return (response.data as List).map((json) => Categoria.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException('Error al obtener categorías: ${e.message}');
    } catch (e) {
      throw ApiException('Error inesperado: $e');
    }
  }

  Future<Categoria> getCategoriaById(String id) async {
    try {
      final response = await dio.get('/api/categorias/$id/');
      return Categoria.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Error al obtener la categoría: ${e.message}');
    }
  }

  Future<Categoria> createCategoria(Categoria categoria) async {
    try {
      final response = await dio.post('/api/categorias/', data: categoria.toJson());
      return Categoria.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Error al crear categoría: ${e.message}');
    }
  }

  Future<Categoria> updateCategoria(Categoria categoria) async {
    try {
      final response = await dio.put('/api/categorias/${categoria.id}/', data: categoria.toJson());
      return Categoria.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Error al actualizar categoría: ${e.message}');
    }
  }

  Future<void> deleteCategoria(String id) async {
    try {
      await dio.delete('/api/categorias/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar categoría: ${e.message}');
    }
  }
}

// Inyección de dependencias con Riverpod
final categoryRemoteDataSourceProvider = Provider<CategoriaRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CategoriaRemoteDataSource(dio);
});