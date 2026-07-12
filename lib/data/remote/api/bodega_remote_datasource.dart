import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import '../../../domain/model/bodega.dart';
import '../../../domain/model/stock_bodega.dart';
import 'dio_client.dart';

class BodegaRemoteDataSource {
  final Dio dio;
  BodegaRemoteDataSource(this.dio);

  Future<List<Bodega>> getBodegas() async {
    try {
      final response = await dio.get('/api/bodegas/');
      return (response.data as List).map((j) => Bodega.fromJson(j)).toList();
    } on DioException catch (e) { throw ApiException('Error obteniendo bodegas: ${e.message}'); }
  }

  // Llama al endpoint custom @action(detail=True, methods=['get'], url_path='inventario')
  Future<List<StockBodega>> getInventarioBodega(String id) async {
    try {
      final response = await dio.get('/api/bodegas/$id/inventario/');
      return (response.data as List).map((j) => StockBodega.fromJson(j)).toList();
    } on DioException catch (e) { throw ApiException('Error obteniendo inventario: ${e.message}'); }
  }

  Future<Bodega> createBodega(Bodega bodega) async {
    try {
      final response = await dio.post('/api/bodegas/', data: bodega.toJson());
      return Bodega.fromJson(response.data);
    } on DioException catch (e) { throw ApiException('Error al crear bodega: ${e.message}'); }
  }

  Future<Bodega> updateBodega(Bodega bodega) async {
    try {
      final response = await dio.put('/api/bodegas/${bodega.id}/', data: bodega.toJson());
      return Bodega.fromJson(response.data);
    } on DioException catch (e) { throw ApiException('Error al actualizar bodega: ${e.message}'); }
  }

  Future<void> deleteBodega(String id) async {
    try {
      await dio.delete('/api/bodegas/$id/');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) throw ApiException('No se puede eliminar bodega con stock.');
      throw ApiException('Error al eliminar: ${e.message}');
    }
  }
}

final bodegaRemoteDataSourceProvider = Provider((ref) => BodegaRemoteDataSource(ref.watch(dioProvider)));