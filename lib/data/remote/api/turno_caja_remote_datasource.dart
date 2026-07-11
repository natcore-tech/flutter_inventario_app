// lib/data/remote/api/turno_caja_remote_datasource.dart
//
// ⚠️ AJUSTA ESTE ARCHIVO si tu proyecto ya tiene un cliente Dio/http distinto.
// Sigue la misma idea que category_remote_datasource.dart: reemplaza
// `_dio`/baseUrl por el cliente que ya usas en el resto de la app.

import 'package:dio/dio.dart';
import '../../../domain/model/turno_caja.dart';

class TurnoCajaRemoteDatasource {
  final Dio _dio;
  TurnoCajaRemoteDatasource(this._dio);

  static const _basePath = '/turnos-caja/';

  /// Lista de turnos (histórico). El backend ya filtra por el cajero
  /// logueado si así está configurado en el ViewSet.
  Future<List<TurnoCaja>> getTurnos() async {
    try {
      final res = await _dio.get(_basePath);
      final list = res.data as List;
      return list.map((e) => TurnoCaja.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// Busca si el cajero actual tiene un turno ABIERTO.
  /// Recorre la lista porque el ViewSet no tiene un @action dedicado.
  Future<TurnoCaja?> getTurnoAbiertoActual() async {
    final turnos = await getTurnos();
    for (final t in turnos) {
      if (t.estaAbierto) return t;
    }
    return null;
  }

  /// Abre un turno nuevo. Solo se manda el monto de apertura;
  /// el backend asigna el cajero automáticamente (request.user).
  Future<TurnoCaja> abrirTurno(double montoApertura) async {
    try {
      final res = await _dio.post(_basePath, data: {
        'monto_apertura': montoApertura,
      });
      return TurnoCaja.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// Cierra un turno existente. `monto_cierre` es obligatorio según
  /// la validación del serializer; `fecha_cierre` la pone el backend.
  Future<TurnoCaja> cerrarTurno({
    required int    id,
    required double montoCierre,
    String           observaciones = '',
  }) async {
    try {
      final res = await _dio.patch('$_basePath$id/', data: {
        'estado':        'CERRADO',
        'monto_cierre':  montoCierre,
        'observaciones': observaciones,
      });
      return TurnoCaja.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      // DRF a veces manda {"non_field_errors": [...]}, o {"monto_cierre": [...]}
      final firstError = data.values.first;
      if (firstError is List && firstError.isNotEmpty) return firstError.first.toString();
      if (firstError is String) return firstError;
    }
    return 'No se pudo completar la operación. Intenta de nuevo.';
  }
}