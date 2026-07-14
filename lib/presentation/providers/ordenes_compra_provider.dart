// lib/presentation/providers/ordenes_compra_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/orden_compra.dart';
import '../../data/remote/api/orden_compra_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class OrdenesCompraState {
  final List<OrdenCompra> ordenes;
  final bool isLoading;
  final String? error;

  const OrdenesCompraState({
    this.ordenes = const [],
    this.isLoading = false,
    this.error,
  });

  OrdenesCompraState copyWith({
    List<OrdenCompra>? ordenes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrdenesCompraState(
      ordenes: ordenes ?? this.ordenes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OrdenesCompraNotifier extends StateNotifier<OrdenesCompraState> {
  final OrdenCompraRemoteDataSource _datasource;

  OrdenesCompraNotifier(this._datasource) : super(const OrdenesCompraState());

  Future<void> cargarOrdenes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getOrdenesCompra();
      state = state.copyWith(isLoading: false, ordenes: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado al cargar las órdenes de compra.');
    }
  }

  Future<bool> crearOrden(OrdenCompra nuevaOrden) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ordenCreada = await _datasource.createOrdenCompra(nuevaOrden);
      
      state = state.copyWith(
        isLoading: false,
        ordenes: [ordenCreada, ...state.ordenes],
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al emitir la orden de compra.');
      return false;
    }
  }

  Future<bool> actualizarEstadoOrden(OrdenCompra orden) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ordenActualizada = await _datasource.updateOrdenCompra(orden);
      
      final nuevaLista = state.ordenes.map((o) {
        return o.id == orden.id ? ordenActualizada : o;
      }).toList();

      state = state.copyWith(isLoading: false, ordenes: nuevaLista);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  Future<bool> eliminarOrden(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.deleteOrdenCompra(id);
      
      final nuevaLista = state.ordenes.where((o) => o.id != id).toList();
      
      state = state.copyWith(isLoading: false, ordenes: nuevaLista);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}


final ordenCompraDatasourceProvider = Provider<OrdenCompraRemoteDataSource>((ref) {
  return OrdenCompraRemoteDataSource(ref.watch(dioProvider));
});

final ordenesCompraProvider = StateNotifierProvider<OrdenesCompraNotifier, OrdenesCompraState>((ref) {
  return OrdenesCompraNotifier(ref.watch(ordenCompraDatasourceProvider));
});