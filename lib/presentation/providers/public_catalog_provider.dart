// lib/presentation/providers/public_catalog_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/producto.dart';
import '../../data/remote/api/producto_remote_datasource.dart';
import 'producto_provider.dart';

class PublicCatalogState {
  final List<Producto> productos;
  final bool isLoading;
  final String? error;

  const PublicCatalogState({
    this.productos = const [],
    this.isLoading = false,
    this.error,
  });

  PublicCatalogState copyWith({
    List<Producto>? productos,
    bool? isLoading,
    String? error,
  }) {
    return PublicCatalogState(
      productos: productos ?? this.productos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PublicCatalogNotifier extends StateNotifier<PublicCatalogState> {
  final ProductoRemoteDataSource _datasource;

  PublicCatalogNotifier(this._datasource) : super(const PublicCatalogState()) {
    cargarDisponibles();
  }

  Future<void> cargarDisponibles() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final lista = await _datasource.getProductosDisponibles();
      state = state.copyWith(isLoading: false, productos: lista);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al cargar el catálogo.');
    }
  }
}

final publicCatalogProvider = StateNotifierProvider<PublicCatalogNotifier, PublicCatalogState>((ref) {
  return PublicCatalogNotifier(ref.watch(productoDatasourceProvider));
});