// lib/data/remote/api/metodo_pago_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_inventario_app/data/remote/api/dio_client.dart';
import 'package:flutter_inventario_app/domain/model/metodo_pago.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetodoPagoRemoteDatasource {
  final Dio _dio;
  MetodoPagoRemoteDatasource(this._dio);

  static const _basePath = '/metodos-pago/';

  Future<List<MetodoPago>> getMetodosPago() async {
    final response = await _dio.get(_basePath);
    if (response.statusCode == 200) {
      final raw = response.data;
      final List<dynamic> data = raw is Map<String, dynamic>
          ? (raw['results'] as List<dynamic>)
          : raw as List<dynamic>;
      return data.map((json) => MetodoPago.fromJson(json)).toList();
    }
    throw Exception('Error al cargar métodos de pago: ${response.statusCode}');
  }

  Future<MetodoPago> createMetodoPago(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(_basePath, data: payload);
      return MetodoPago.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<MetodoPago> updateMetodoPago(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.patch('$_basePath$id/', data: payload);
      return MetodoPago.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteMetodoPago(int id) async {
    final response = await _dio.delete('$_basePath$id/');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar el método de pago');
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final firstError = data.values.first;
      if (firstError is List && firstError.isNotEmpty) return firstError.first.toString();
      if (firstError is String) return firstError;
    }
    return 'No se pudo completar la operación. Intenta de nuevo.';
  }
}

final metodoPagoDatasourceProvider =
    Provider<MetodoPagoRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return MetodoPagoRemoteDatasource(dio);
});