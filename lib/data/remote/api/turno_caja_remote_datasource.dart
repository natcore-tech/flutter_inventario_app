// lib/data/remote/api/turno_caja_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_inventario_app/data/remote/api/dio_client.dart';
import 'package:flutter_inventario_app/domain/model/turno_caja.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TurnoCajaRemoteDatasource {
  final Dio _dio;

  TurnoCajaRemoteDatasource(this._dio);

  static const _basePath = '/turnos-caja/';

  Future<List<TurnoCaja>> getTurnos() async {
    final response = await _dio.get(_basePath);
    if (response.statusCode == 200) {
      final raw = response.data;
      final List<dynamic> data = raw is Map<String, dynamic>
          ? (raw['results'] as List<dynamic>)
          : raw as List<dynamic>;
      return data.map((json) => TurnoCaja.fromJson(json)).toList();
    }
    throw Exception('Error al cargar turnos: ${response.statusCode}');
  }

  Future<TurnoCaja?> getTurnoAbiertoActual() async {
    final turnos = await getTurnos();
    for (final t in turnos) {
      if (t.estaAbierto) return t;
    }
    return null;
  }

  Future<TurnoCaja> abrirTurno(double montoApertura) async {
    final response = await _dio.post(_basePath, data: {
      'monto_apertura': montoApertura,
    });
    return TurnoCaja.fromJson(response.data);
  }

  Future<TurnoCaja> cerrarTurno({
    required int id,
    required double montoCierre,
    String observaciones = '',
  }) async {
    final response = await _dio.patch('$_basePath$id/', data: {
      'estado': 'CERRADO',
      'monto_cierre': montoCierre,
      'observaciones': observaciones,
    });
    return TurnoCaja.fromJson(response.data);
  }
}

final turnoCajaDatasourceProvider = Provider<TurnoCajaRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return TurnoCajaRemoteDatasource(dio);
});
