import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import 'dio_client.dart';
import '../../../domain/model/marca.dart';

class MarcaRemoteDataSource {
    final Dio dio;

    MarcaRemoteDataSource(this.dio);

    Future<List<Marca>> getMarcas() async {
        try {
            final response = await dio.get('/api/marcas/');
            return (response.data as List).map((json) => Marca.fromJson(json)).toList();
        } on DioException catch (e) {
            throw ApiException('Error al obtener marcas: ${e.message}');
        } catch (e) {
            throw ApiException('Error inesperado: $e');
        }
    }

    Future<Marca> getMarcaById(String id) async {
        try {
            final response = await dio.get('/api/marcas/$id/');
            return Marca.fromJson(response.data);
        } on DioException catch (e) {
            throw ApiException('Error al obtener la marca: ${e.message}');
        } catch (e) {
            throw ApiException('Error inesperado: $e');
        }
    }

    Future<Marca> createMarca(Marca marca) async {
        try {
            final response = await dio.post('/api/marcas/', data: marca.toJson());
            return Marca.fromJson(response.data);
        } on DioException catch (e) {
            throw ApiException('Error al crear marca: ${e.message}');
        } catch (e) {
            throw ApiException('Error inesperado: $e');
        }
    }

    Future<Marca> updateMarca(Marca marca) async {
        try {
            final response = await dio.put('/api/marcas/${marca.id}/', data: marca.toJson());
            return Marca.fromJson(response.data);
            } on DioException catch (e) {
        throw ApiException('Error al actualizar marca: ${e.message}');
        } catch (e) {
            throw ApiException('Error inesperado: $e');
        }
    }

    Future<void> deleteMarca(String id) async {
        try {
            await dio.delete('/api/marcas/$id/');
            } on DioException catch (e) {
        throw ApiException('Error al eliminar marca: ${e.message}');
        } catch (e) {
            throw ApiException('Error inesperado: $e');
        }
    }
}

// Inyección de dependencias con Riverpod
final marcaRemoteDataSourceProvider = Provider<MarcaRemoteDataSource>((ref) {
  // Ajusta 'dioProvider' por el nombre real de tu provider en dio_client.dart
    final dio = ref.watch(dioProvider); 
    return MarcaRemoteDataSource(dio);
});