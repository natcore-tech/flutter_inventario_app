// lib/data/remote/api/movimiento_inventario_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../domain/model/movimiento_inventario.dart';
import '../../../core/error/api_exception.dart';

class MovimientoInventarioRemoteDataSource {
  final Dio _dio;

  MovimientoInventarioRemoteDataSource(this._dio);

  Future<List<MovimientoInventario>> getMovimientos() async {
    try {
      final response = await _dio.get('/movimientos/');
      final data = response.data as List;
      return data.map((json) => MovimientoInventario.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MovimientoInventario> createMovimiento(MovimientoInventario movimiento) async {
    try {
      final response = await _dio.post(
        '/movimientos/',
        data: movimiento.toJson(),
      );
      return MovimientoInventario.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MovimientoInventario> updateMovimiento(MovimientoInventario movimiento) async {
    try {
      final response = await _dio.put(
        '/movimientos/${movimiento.id}/',
        data: movimiento.toJson(),
      );
      return MovimientoInventario.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteMovimiento(int id) async {
    try {
      await _dio.delete('/movimientos/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}