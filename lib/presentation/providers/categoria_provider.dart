// lib/presentation/providers/categoria_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/categoria.dart';
import '../../data/remote/api/categoria_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class CategoriasState {
  final List<Categoria> categorias;
  final bool isLoading;
  final String? error;

  const CategoriasState({
    this.categorias = const [],
    this.isLoading = false,
    this.error,
  });

  CategoriasState copyWith({
    List<Categoria>? categorias,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CategoriasState(
      categorias: categorias ?? this.categorias,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CategoriasNotifier extends StateNotifier<CategoriasState> {
  final CategoriaRemoteDataSource _datasource;

  CategoriasNotifier(this._datasource) : super(const CategoriasState());

  Future<void> cargarCategorias() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getCategorias();
      state = state.copyWith(isLoading: false, categorias: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado al cargar las categorías.');
    }
  }

  Future<bool> guardarCategoria(Categoria categoria) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (categoria.id == null) {
        final nueva = await _datasource.createCategoria(categoria);
        state = state.copyWith(
          isLoading: false,
          categorias: [...state.categorias, nueva]..sort((a, b) => a.nombre.compareTo(b.nombre)),
        );
      } else {
        final actualizada = await _datasource.updateCategoria(categoria);
        final lista = state.categorias.map((c) => c.id == categoria.id ? actualizada : c).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        state = state.copyWith(isLoading: false, categorias: lista);
      }
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al guardar la categoría.');
      return false;
    }
  }

  Future<bool> eliminarCategoria(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.deleteCategoria(id);
      final lista = state.categorias.where((c) => c.id != id).toList();
      state = state.copyWith(isLoading: false, categorias: lista);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al eliminar la categoría.');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final categoriaDatasourceProvider = Provider<CategoriaRemoteDataSource>((ref) {
  return CategoriaRemoteDataSource(ref.watch(dioProvider));
});

final categoriasProvider = StateNotifierProvider<CategoriasNotifier, CategoriasState>((ref) {
  return CategoriasNotifier(ref.watch(categoriaDatasourceProvider));
});