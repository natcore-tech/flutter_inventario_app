// lib/presentation/providers/unidad_medida_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/unidad_medida.dart';
import '../../data/remote/api/unidad_medida_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class UnidadesMedidaState {
  final List<UnidadMedida> unidades;
  final bool isLoading;
  final String? error;

  const UnidadesMedidaState({
    this.unidades = const [],
    this.isLoading = false,
    this.error,
  });

  UnidadesMedidaState copyWith({
    List<UnidadMedida>? unidades,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UnidadesMedidaState(
      unidades: unidades ?? this.unidades,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class UnidadesMedidaNotifier extends StateNotifier<UnidadesMedidaState> {
  final UnidadMedidaRemoteDataSource _datasource;

  UnidadesMedidaNotifier(this._datasource) : super(const UnidadesMedidaState());

  Future<void> cargarUnidades() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getUnidades();
      state = state.copyWith(isLoading: false, unidades: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado al cargar las unidades.');
    }
  }

  Future<bool> guardarUnidad(UnidadMedida unidad) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (unidad.id == null) {
        final nueva = await _datasource.createUnidad(unidad);
        state = state.copyWith(
          isLoading: false,
          unidades: [...state.unidades, nueva]..sort((a, b) => a.nombre.compareTo(b.nombre)),
        );
      } else {
        final actualizada = await _datasource.updateUnidad(unidad);
        final lista = state.unidades.map((u) => u.id == unidad.id ? actualizada : u).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        state = state.copyWith(isLoading: false, unidades: lista);
      }
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al guardar la unidad de medida.');
      return false;
    }
  }

  Future<bool> eliminarUnidad(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.deleteUnidad(id);
      final lista = state.unidades.where((u) => u.id != id).toList();
      state = state.copyWith(isLoading: false, unidades: lista);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al eliminar la unidad de medida.');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final unidadMedidaDatasourceProvider = Provider<UnidadMedidaRemoteDataSource>((ref) {
  return UnidadMedidaRemoteDataSource(ref.watch(dioProvider));
});

final unidadesMedidaProvider = StateNotifierProvider<UnidadesMedidaNotifier, UnidadesMedidaState>((ref) {
  return UnidadesMedidaNotifier(ref.watch(unidadMedidaDatasourceProvider));
});