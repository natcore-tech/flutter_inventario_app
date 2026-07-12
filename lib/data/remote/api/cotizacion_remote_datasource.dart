// lib/data/remote/api/cotizacion_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_inventario_app/data/remote/api/dio_client.dart';
import 'package:flutter_inventario_app/presentation/domain/model/cotizacion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CotizacionRemoteDatasource {
  final Dio _dio;
  CotizacionRemoteDatasource(this._dio);

  static const _basePath = '/cotizaciones/';

  Future<List<Cotizacion>> getCotizaciones() async {
    final response = await _dio.get(_basePath);
    if (response.statusCode == 200) {
      final raw = response.data;
      final List<dynamic> data = raw is Map<String, dynamic>
          ? (raw['results'] as List<dynamic>)
          : raw as List<dynamic>;
      return data.map((json) => Cotizacion.fromJson(json)).toList();
    }
    throw Exception('Error al cargar cotizaciones: ${response.statusCode}');
  }

  Future<Cotizacion> crearCotizacion({
    required int proveedorId,
    required String codigoCotizacion,
    required DateTime fechaValidez,
    required double totalPropuesto,
    required List<CotizacionDetalle> detalles,
  }) async {
    try {
      final response = await _dio.post(_basePath, data: {
        'proveedor':          proveedorId,
        'codigo_cotizacion':  codigoCotizacion,
        'fecha_validez':      fechaValidez.toIso8601String().split('T').first,
        'total_propuesto':    totalPropuesto,
        'detalles':           detalles.map((d) => d.toPayload()).toList(),
      });
      return Cotizacion.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteCotizacion(int id) async {
    final response = await _dio.delete('$_basePath$id/');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar la cotización');
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

final cotizacionDatasourceProvider = Provider<CotizacionRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return CotizacionRemoteDatasource(dio);
});