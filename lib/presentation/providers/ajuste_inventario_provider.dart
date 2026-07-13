// lib/presentation/providers/ajuste_inventario_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/ajuste_inventario.dart';
import '../../data/remote/api/ajuste_inventario_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class AjustesInventarioState {
  final List<AjusteInventario> ajustes;
  final bool isLoading;
  final String? error;

  const AjustesInventarioState({
    this.ajustes = const [],
    this.isLoading = false,
    this.error,
  });

  AjustesInventarioState copyWith({
    List<AjusteInventario>? ajustes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AjustesInventarioState(
      ajustes: ajustes ?? this.ajustes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AjustesInventarioNotifier extends StateNotifier<AjustesInventarioState> {
  final AjusteInventarioRemoteDataSource _datasource;

  AjustesInventarioNotifier(this._datasource) : super(const AjustesInventarioState());

  Future<void> cargarAjustes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getAjustes();
      state = state.copyWith(isLoading: false, ajustes: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado al cargar los ajustes.');
    }
  }

  Future<bool> registrarAjuste(AjusteInventario nuevoAjuste) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ajusteCreado = await _datasource.createAjuste(nuevoAjuste);
      state = state.copyWith(
        isLoading: false,
        ajustes: [ajusteCreado, ...state.ajustes],
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al registrar el ajuste.');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final ajusteDatasourceProvider = Provider<AjusteInventarioRemoteDataSource>((ref) {
  return AjusteInventarioRemoteDataSource(ref.watch(dioProvider));
});

final ajustesInventarioProvider = StateNotifierProvider<AjustesInventarioNotifier, AjustesInventarioState>((ref) {
  return AjustesInventarioNotifier(ref.watch(ajusteDatasourceProvider));
});