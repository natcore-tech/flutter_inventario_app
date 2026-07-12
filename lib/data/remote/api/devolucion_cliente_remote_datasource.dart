// lib/data/remote/api/devolucion_cliente_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_inventario_app/data/remote/api/dio_client.dart';
import 'package:flutter_inventario_app/presentation/domain/model/devolucion_cliente.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DevolucionClienteRemoteDatasource {
  final Dio _dio;
  DevolucionClienteRemoteDatasource(this._dio);

  static const _basePath = '/devoluciones/';

  Future<List<DevolucionCliente>> getDevoluciones() async {
    final response = await _dio.get(_basePath);
    if (response.statusCode == 200) {
      final raw = response.data;
      final List<dynamic> data = raw is Map<String, dynamic>
          ? (raw['results'] as List<dynamic>)
          : raw as List<dynamic>;
      return data.map((json) => DevolucionCliente.fromJson(json)).toList();
    }
    throw Exception('Error al cargar devoluciones: ${response.statusCode}');
  }

  Future<DevolucionCliente> createDevolucion(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(_basePath, data: payload);
      return DevolucionCliente.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteDevolucion(int id) async {
    final response = await _dio.delete('$_basePath$id/');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar la devolución');
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

final devolucionClienteDatasourceProvider =
    Provider<DevolucionClienteRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return DevolucionClienteRemoteDatasource(dio);
});