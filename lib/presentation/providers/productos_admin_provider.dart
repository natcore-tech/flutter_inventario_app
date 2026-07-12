// lib/presentation/providers/admin/productos_admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api/producto_lite_remote_datasource.dart';
import '../../../domain/model/producto_lite.dart';

class ProductosAdminState {
  final List<ProductoLite> productos;
  final bool isLoading;
  final String? error;

  const ProductosAdminState({
    this.productos = const [],
    this.isLoading = false,
    this.error,
  });

  ProductosAdminState copyWith({
    List<ProductoLite>? productos,
    bool? isLoading,
    String? error,
  }) => ProductosAdminState(
    productos: productos ?? this.productos,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class ProductosAdminNotifier extends StateNotifier<ProductosAdminState> {
  final ProductoLiteRemoteDatasource _datasource;

  ProductosAdminNotifier(this._datasource) : super(const ProductosAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _datasource.getProductos();
      state = state.copyWith(productos: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createProducto(Map<String, dynamic> payload) async {
    final created = await _datasource.createProducto(payload);
    state = state.copyWith(productos: [created, ...state.productos]);
  }
}

final productosAdminProvider =
    StateNotifierProvider<ProductosAdminNotifier, ProductosAdminState>((ref) {
  return ProductosAdminNotifier(ref.watch(productoLiteDatasourceProvider));
});