// lib/presentation/providers/marca_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/marca.dart';
import '../../data/remote/api/marca_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class MarcasState {
  final List<Marca> marcas;
  final bool isLoading;
  final String? error;

  const MarcasState({
    this.marcas = const [],
    this.isLoading = false,
    this.error,
  });

  MarcasState copyWith({
    List<Marca>? marcas,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MarcasState(
      marcas: marcas ?? this.marcas,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MarcasNotifier extends StateNotifier<MarcasState> {
  final MarcaRemoteDataSource _datasource;

  MarcasNotifier(this._datasource) : super(const MarcasState());

  Future<void> cargarMarcas() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getMarcas();
      state = state.copyWith(isLoading: false, marcas: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado al cargar las marcas.');
    }
  }

  Future<bool> guardarMarca(Marca marca) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (marca.id == null) {
        // Crear
        final nueva = await _datasource.createMarca(marca);
        state = state.copyWith(
          isLoading: false,
          marcas: [...state.marcas, nueva]..sort((a, b) => a.nombre.compareTo(b.nombre)),
        );
      } else {
        // Actualizar
        final actualizada = await _datasource.updateMarca(marca);
        final lista = state.marcas.map((m) => m.id == marca.id ? actualizada : m).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        state = state.copyWith(isLoading: false, marcas: lista);
      }
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al guardar la marca.');
      return false;
    }
  }

  Future<bool> eliminarMarca(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.deleteMarca(id);
      final lista = state.marcas.where((m) => m.id != id).toList();
      state = state.copyWith(isLoading: false, marcas: lista);
      return true;
    } on ApiException catch (e) {
      // Aquí se atrapará el mensaje "No se puede eliminar la marca porque tiene productos..."
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al eliminar la marca.');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final marcaDatasourceProvider = Provider<MarcaRemoteDataSource>((ref) {
  return MarcaRemoteDataSource(ref.watch(dioProvider));
});

final marcasProvider = StateNotifierProvider<MarcasNotifier, MarcasState>((ref) {
  return MarcasNotifier(ref.watch(marcaDatasourceProvider));
});