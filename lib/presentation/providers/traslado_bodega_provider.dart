// lib/presentation/providers/traslado_bodega_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/traslado_bodega.dart';
import '../../data/remote/api/traslado_bodega_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class TrasladosBodegaState {
  final List<TrasladoBodega> traslados;
  final bool isLoading;
  final String? error;

  const TrasladosBodegaState({
    this.traslados = const [],
    this.isLoading = false,
    this.error,
  });

  TrasladosBodegaState copyWith({
    List<TrasladoBodega>? traslados,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TrasladosBodegaState(
      traslados: traslados ?? this.traslados,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TrasladosBodegaNotifier extends StateNotifier<TrasladosBodegaState> {
  final TrasladoBodegaRemoteDataSource _datasource;

  TrasladosBodegaNotifier(this._datasource) : super(const TrasladosBodegaState());

  Future<void> cargarTraslados() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getTraslados();
      state = state.copyWith(isLoading: false, traslados: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al cargar los traslados.');
    }
  }

  Future<bool> registrarTraslado(TrasladoBodega nuevoTraslado) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final creado = await _datasource.createTraslado(nuevoTraslado);
      state = state.copyWith(
        isLoading: false,
        traslados: [creado, ...state.traslados],
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al crear el traslado.');
      return false;
    }
  }

  Future<bool> completarTraslado(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.completarTraslado(id);
      
      final listaActualizada = state.traslados.map((t) {
        if (t.id == id) {
          return TrasladoBodega(
            id: t.id,
            fechaTraslado: t.fechaTraslado,
            bodegaOrigenId: t.bodegaOrigenId,
            bodegaOrigenNombre: t.bodegaOrigenNombre,
            bodegaDestinoId: t.bodegaDestinoId,
            bodegaDestinoNombre: t.bodegaDestinoNombre,
            estado: 'COMPLETADO', // Cambiamos el estado localmente
            detalles: t.detalles,
          );
        }
        return t;
      }).toList();

      state = state.copyWith(isLoading: false, traslados: listaActualizada);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al completar el traslado.');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final trasladoDatasourceProvider = Provider<TrasladoBodegaRemoteDataSource>((ref) {
  return TrasladoBodegaRemoteDataSource(ref.watch(dioProvider));
});

final trasladosBodegaProvider = StateNotifierProvider<TrasladosBodegaNotifier, TrasladosBodegaState>((ref) {
  return TrasladosBodegaNotifier(ref.watch(trasladoDatasourceProvider));
});