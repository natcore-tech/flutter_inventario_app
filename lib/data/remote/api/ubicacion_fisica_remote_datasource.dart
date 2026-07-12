import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import '../../../domain/model/ubicacion_fisica.dart';
import 'dio_client.dart';

class UbicacionFisicaRemoteDataSource {
  final Dio dio;
  UbicacionFisicaRemoteDataSource(this.dio);

  Future<List<UbicacionFisica>> getUbicaciones() async {
    try {
      final response = await dio.get('/api/ubicaciones/');
      return (response.data as List).map((j) => UbicacionFisica.fromJson(j)).toList();
    } on DioException catch (e) { throw ApiException('Error obteniendo ubicaciones: ${e.message}'); }
  }

  Future<Map<String, dynamic>> verificarDisponibilidad(String id) async {
    try {
      final response = await dio.get('/api/ubicaciones/$id/disponibilidad/');
      return response.data;
    } on DioException catch (e) { throw ApiException('Error verificando ubicación: ${e.message}'); }
  }

  Future<UbicacionFisica> createUbicacion(UbicacionFisica ubicacion) async {
    try {
      final response = await dio.post('/api/ubicaciones/', data: ubicacion.toJson());
      return UbicacionFisica.fromJson(response.data);
    } on DioException catch (e) { throw ApiException('Error al crear: ${e.message}'); }
  }

  Future<UbicacionFisica> updateUbicacion(UbicacionFisica ubicacion) async {
    try {
      final response = await dio.put('/api/ubicaciones/${ubicacion.id}/', data: ubicacion.toJson());
      return UbicacionFisica.fromJson(response.data);
    } on DioException catch (e) { throw ApiException('Error al actualizar: ${e.message}'); }
  }

  Future<void> deleteUbicacion(String id) async {
    try {
      await dio.delete('/api/ubicaciones/$id/');
    } on DioException catch (e) { throw ApiException('Error al eliminar: ${e.message}'); }
  }
}

final ubicacionFisicaRemoteDataSourceProvider = Provider((ref) => UbicacionFisicaRemoteDataSource(ref.watch(dioProvider)));