// lib/presentation/providers/movimiento_inventario_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/movimiento_inventario.dart';
import '../../data/remote/api/movimiento_inventario_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class MovimientosInventarioState {
  final List<MovimientoInventario> movimientos;
  final bool isLoading;
  final String? error;

  const MovimientosInventarioState({
    this.movimientos = const [],
    this.isLoading = false,
    this.error,
  });

  MovimientosInventarioState copyWith({
    List<MovimientoInventario>? movimientos,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MovimientosInventarioState(
      movimientos: movimientos ?? this.movimientos,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MovimientosInventarioNotifier extends StateNotifier<MovimientosInventarioState> {
  final MovimientoInventarioRemoteDataSource _datasource;

  MovimientosInventarioNotifier(this._datasource) : super(const MovimientosInventarioState());

  Future<void> cargarMovimientos() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getMovimientos();
      state = state.copyWith(isLoading: false, movimientos: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado al cargar los movimientos.');
    }
  }

  Future<bool> registrarMovimiento(MovimientoInventario nuevoMovimiento) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final movCreado = await _datasource.createMovimiento(nuevoMovimiento);
      state = state.copyWith(
        isLoading: false,
        movimientos: [movCreado, ...state.movimientos],
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al registrar el movimiento.');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final movimientoDatasourceProvider = Provider<MovimientoInventarioRemoteDataSource>((ref) {
  return MovimientoInventarioRemoteDataSource(ref.watch(dioProvider));
});

final movimientosInventarioProvider = StateNotifierProvider<MovimientosInventarioNotifier, MovimientosInventarioState>((ref) {
  return MovimientosInventarioNotifier(ref.watch(movimientoDatasourceProvider));
});