// lib/presentation/providers/proveedores_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/proveedor.dart';
import '../../data/remote/api/proveedor_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class ProveedoresState {
  final List<Proveedor> proveedores;
  final bool isLoading;
  final String? error;

  const ProveedoresState({
    this.proveedores = const [],
    this.isLoading = false,
    this.error,
  });

  ProveedoresState copyWith({
    List<Proveedor>? proveedores,
    bool? isLoading,
    String? error,
    bool clearError = false, 
  }) {
    return ProveedoresState(
      proveedores: proveedores ?? this.proveedores,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProveedoresNotifier extends StateNotifier<ProveedoresState> {
  final ProveedorRemoteDataSource _datasource;

  ProveedoresNotifier(this._datasource) : super(const ProveedoresState());

  Future<void> cargarProveedores() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getProveedores();
      state = state.copyWith(isLoading: false, proveedores: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado al cargar proveedores.');
    }
  }

  Future<bool> agregarProveedor(Proveedor nuevoProveedor) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final proveedorCreado = await _datasource.createProveedor(nuevoProveedor);
      
      state = state.copyWith(
        isLoading: false,
        proveedores: [...state.proveedores, proveedorCreado],
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al guardar el proveedor.');
      return false;
    }
  }

  Future<bool> actualizarProveedor(Proveedor proveedor) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final proveedorActualizado = await _datasource.updateProveedor(proveedor);
      
      final nuevaLista = state.proveedores.map((p) {
        return p.id == proveedor.id ? proveedorActualizado : p;
      }).toList();

      state = state.copyWith(isLoading: false, proveedores: nuevaLista);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  Future<bool> eliminarProveedor(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.deleteProveedor(id);
      
      final nuevaLista = state.proveedores.where((p) => p.id != id).toList();
      
      state = state.copyWith(isLoading: false, proveedores: nuevaLista);
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


final proveedorDatasourceProvider = Provider<ProveedorRemoteDataSource>((ref) {
  return ProveedorRemoteDataSource(ref.watch(dioProvider));
});

final proveedoresProvider = StateNotifierProvider<ProveedoresNotifier, ProveedoresState>((ref) {
  return ProveedoresNotifier(ref.watch(proveedorDatasourceProvider));
});