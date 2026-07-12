import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import '../../../domain/model/stock_bodega.dart';
import 'dio_client.dart';

class StockBodegaRemoteDataSource {
  final Dio dio;
  StockBodegaRemoteDataSource(this.dio);

  Future<List<StockBodega>> getAllStock({String? bodegaId, String? productoId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (bodegaId != null) queryParams['bodega'] = bodegaId;
      if (productoId != null) queryParams['producto'] = productoId;

      final response = await dio.get('/api/stock-bodegas/', queryParameters: queryParams);
      return (response.data as List).map((j) => StockBodega.fromJson(j)).toList();
    } on DioException catch (e) { throw ApiException('Error obteniendo stock: ${e.message}'); }
  }

  Future<StockBodega> updateStock(StockBodega stock) async {
    try {
      final response = await dio.put('/api/stock-bodegas/${stock.id}/', data: stock.toJson());
      return StockBodega.fromJson(response.data);
    } on DioException catch (e) { throw ApiException('Error actualizando stock: ${e.message}'); }
  }
}

final stockBodegaRemoteDataSourceProvider = Provider((ref) => StockBodegaRemoteDataSource(ref.watch(dioProvider)));