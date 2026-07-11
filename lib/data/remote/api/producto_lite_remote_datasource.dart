// lib/data/remote/api/producto_lite_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_inventario_app/data/remote/api/dio_client.dart';
import 'package:flutter_inventario_app/domain/model/producto_lite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductoLiteRemoteDatasource {
  final Dio _dio;
  ProductoLiteRemoteDatasource(this._dio);

  static const _basePath = '/productos/';

  Future<List<ProductoLite>> getProductos({String? search}) async {
    final response = await _dio.get(_basePath, queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
    if (response.statusCode == 200) {
      final raw = response.data;
      final List<dynamic> data = raw is Map<String, dynamic>
          ? (raw['results'] as List<dynamic>)
          : raw as List<dynamic>;
      return data
          .map((json) => ProductoLite.fromJson(json))
          .where((p) => p.esActivo)
          .toList();
    }
    throw Exception('Error al cargar productos: ${response.statusCode}');
  }

  Future<ProductoLite> createProducto(Map<String, dynamic> payload) async {
    final response = await _dio.post(_basePath, data: payload);
    return ProductoLite.fromJson(response.data);
  }
}

final productoLiteDatasourceProvider =
    Provider<ProductoLiteRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductoLiteRemoteDatasource(dio);
});