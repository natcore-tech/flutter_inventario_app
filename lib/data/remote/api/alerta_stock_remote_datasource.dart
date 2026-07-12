import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import '../../../domain/model/alerta_stock_minimo.dart';
import 'dio_client.dart';

class AlertaStockRemoteDataSource {
  final Dio dio;
  AlertaStockRemoteDataSource(this.dio);

  Future<List<AlertaStockMinimo>> getAlertas() async {
    try {
      final response = await dio.get('/api/alertas-stock/');
      return (response.data as List).map((j) => AlertaStockMinimo.fromJson(j)).toList();
    } on DioException catch (e) { throw ApiException('Error obteniendo alertas: ${e.message}'); }
  }

  Future<AlertaStockMinimo> createAlerta(AlertaStockMinimo alerta) async {
    try {
      final response = await dio.post('/api/alertas-stock/', data: alerta.toJson());
      return AlertaStockMinimo.fromJson(response.data);
    } on DioException catch (e) { throw ApiException('Error creando alerta: ${e.message}'); }
  }

  Future<AlertaStockMinimo> updateAlerta(AlertaStockMinimo alerta) async {
    try {
      final response = await dio.put('/api/alertas-stock/${alerta.id}/', data: alerta.toJson());
      return AlertaStockMinimo.fromJson(response.data);
    } on DioException catch (e) { throw ApiException('Error actualizando alerta: ${e.message}'); }
  }
}

final alertaStockRemoteDataSourceProvider = Provider((ref) => AlertaStockRemoteDataSource(ref.watch(dioProvider)));