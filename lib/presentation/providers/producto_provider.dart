// lib/presentation/providers/producto_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/producto.dart';
import '../../data/remote/api/producto_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class ProductosState {
  final List<Producto> productos;
  final bool isLoading;
  final String? error;

  const ProductosState({
    this.productos = const [],
    this.isLoading = false,
    this.error,
  });

  ProductosState copyWith({
    List<Producto>? productos,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProductosState(
      productos: productos ?? this.productos,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductosNotifier extends StateNotifier<ProductosState> {
  final ProductoRemoteDataSource _datasource;

  ProductosNotifier(this._datasource) : super(const ProductosState());

  Future<void> cargarProductos() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getProductos();
      state = state.copyWith(isLoading: false, productos: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado al cargar productos.');
    }
  }

  Future<bool> guardarProducto(Producto producto) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (producto.id == null) {
        final nuevo = await _datasource.createProducto(producto);
        state = state.copyWith(
          isLoading: false,
          productos: [...state.productos, nuevo]..sort((a, b) => a.nombre.compareTo(b.nombre)),
        );
      } else {
        final actualizado = await _datasource.updateProducto(producto);
        final lista = state.productos.map((p) => p.id == producto.id ? actualizado : p).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        state = state.copyWith(isLoading: false, productos: lista);
      }
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al guardar el producto.');
      return false;
    }
  }

  Future<bool> eliminarProducto(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.deleteProducto(id);
      final lista = state.productos.where((p) => p.id != id).toList();
      state = state.copyWith(isLoading: false, productos: lista);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al eliminar producto.');
      return false;
    }
  }

  Future<bool> reabastecerProducto(int id, int cantidad) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.reabastecerProducto(id, cantidad);
      // Recargar la lista para obtener los datos actualizados con las categorías anidadas
      await cargarProductos();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al reabastecer el stock.');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final productoDatasourceProvider = Provider<ProductoRemoteDataSource>((ref) {
  return ProductoRemoteDataSource(ref.watch(dioProvider));
});

final productosProvider = StateNotifierProvider<ProductosNotifier, ProductosState>((ref) {
  return ProductosNotifier(ref.watch(productoDatasourceProvider));
});