// lib/data/remote/api/venta_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_inventario_app/data/remote/api/dio_client.dart';
import 'package:flutter_inventario_app/presentation/domain/model/venta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VentaRemoteDatasource {
  final Dio _dio;
  VentaRemoteDatasource(this._dio);

  static const _basePath = '/ventas/';

  Future<List<Venta>> getVentas() async {
    final response = await _dio.get(_basePath);
    if (response.statusCode == 200) {
      final raw = response.data;
      final List<dynamic> data = raw is Map<String, dynamic>
          ? (raw['results'] as List<dynamic>)
          : raw as List<dynamic>;
      return data.map((json) => Venta.fromJson(json)).toList();
    }
    throw Exception('Error al cargar ventas: ${response.statusCode}');
  }


  Future<Venta> crearVenta({
    required int clienteId,
    required List<VentaDetalle> detalles,
    List<PagoVenta> pagos = const [],
  }) async {
    try {
      final response = await _dio.post(_basePath, data: {
        'cliente':  clienteId,
        'detalles': detalles.map((d) => d.toPayload()).toList(),
        'pagos':    pagos.map((p) => p.toPayload()).toList(),
      });
      return Venta.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final firstError = data.values.first;
      if (firstError is List && firstError.isNotEmpty) return firstError.first.toString();
      if (firstError is String) return firstError;
    }
    return 'No se pudo registrar la venta. Intenta de nuevo.';
  }
}

final ventaDatasourceProvider = Provider<VentaRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return VentaRemoteDatasource(dio);
});