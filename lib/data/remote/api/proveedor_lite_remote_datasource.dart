// lib/data/remote/api/proveedor_lite_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_inventario_app/data/remote/api/dio_client.dart';
import 'package:flutter_inventario_app/presentation/domain/model/proveedor_lite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProveedorLiteRemoteDatasource {
  final Dio _dio;
  ProveedorLiteRemoteDatasource(this._dio);

  static const _basePath = '/proveedores/';

  Future<List<ProveedorLite>> getProveedores() async {
    final response = await _dio.get(_basePath);
    if (response.statusCode == 200) {
      final raw = response.data;
      final List<dynamic> data = raw is Map<String, dynamic>
          ? (raw['results'] as List<dynamic>)
          : raw as List<dynamic>;
      return data
          .map((json) => ProveedorLite.fromJson(json))
          .where((p) => p.esActivo)
          .toList();
    }
    throw Exception('Error al cargar proveedores: ${response.statusCode}');
  }
}

final proveedorLiteDatasourceProvider =
    Provider<ProveedorLiteRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProveedorLiteRemoteDatasource(dio);
});