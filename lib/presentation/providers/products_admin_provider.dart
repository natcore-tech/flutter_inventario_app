// lib/presentation/providers/products_admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/product_remote_datasource.dart';
import '../../domain/model/product.dart';

enum ProductStockFilter { all, inStock, outOfStock, active, inactive }

extension ProductStockFilterLabel on ProductStockFilter {
  String get label => switch (this) {
    ProductStockFilter.all        => 'Todos',
    ProductStockFilter.inStock    => 'Con stock',
    ProductStockFilter.outOfStock => 'Sin stock',
    ProductStockFilter.active     => 'Activos',
    ProductStockFilter.inactive   => 'Inactivos',
  };
}

class ProductsAdminState {
  final List<Product>      products;
  final bool               isLoading;
  final String?            error;
  final int                total;
  final String             search;
  final ProductStockFilter stockFilter;
  final ProductFormState   formState;

  const ProductsAdminState({
    this.products    = const [],
    this.isLoading   = false,
    this.error,
    this.total       = 0,
    this.search      = '',
    this.stockFilter = ProductStockFilter.all,
    this.formState   = const ProductFormIdle(),
  });

  List<Product> get filtered => products.where((p) {
    final matchSearch = search.isEmpty ||
        p.name.toLowerCase().contains(search.toLowerCase());
    final matchFilter = switch (stockFilter) {
      ProductStockFilter.all        => true,
      ProductStockFilter.inStock    => p.stock > 0,
      ProductStockFilter.outOfStock => p.stock == 0,
      ProductStockFilter.active     => p.isActive,
      ProductStockFilter.inactive   => !p.isActive,
    };
    return matchSearch && matchFilter;
  }).toList();

  ProductsAdminState copyWith({
    List<Product>?      products,
    bool?               isLoading,
    String?             error,
    bool                clearError = false,
    int?                total,
    String?             search,
    ProductStockFilter? stockFilter,
    ProductFormState?   formState,
  }) => ProductsAdminState(
    products:    products    ?? this.products,
    isLoading:   isLoading   ?? this.isLoading,
    error:       clearError  ? null : (error ?? this.error),
    total:       total       ?? this.total,
    search:      search      ?? this.search,
    stockFilter: stockFilter ?? this.stockFilter,
    formState:   formState   ?? this.formState,
  );
}

sealed class ProductFormState { const ProductFormState(); }
class ProductFormIdle    extends ProductFormState { const ProductFormIdle(); }
// CORREGIDO: Ahora el constructor coincide con el nombre de la clase
class ProductFormSaving  extends ProductFormState { const ProductFormSaving(); } 
class ProductFormSuccess extends ProductFormState {
  final String message;
  const ProductFormSuccess(this.message);
}
class ProductFormError extends ProductFormState {
  final String message;
  const ProductFormError(this.message);
}

class ProductsAdminNotifier extends StateNotifier<ProductsAdminState> {
  final ProductRemoteDatasource _datasource;

  ProductsAdminNotifier(this._datasource) : super(const ProductsAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _datasource.getProducts(pageSize: 50);
      final List<Product> loadedProducts = List<Product>.from(result.results);
      state = state.copyWith(
        products:  loadedProducts,
        total:     result.count,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearch(String q)           => state = state.copyWith(search: q);
  void setStockFilter(ProductStockFilter f) => state = state.copyWith(stockFilter: f);

  // Toggle optimista
  Future<void> toggleActive(int id, bool isActive) async {
    // CORREGIDO: Se añade stock de forma explícita al copyWith de Product
    final updatedProducts = state.products.map<Product>((p) =>
      p.id == id ? p.copyWith(isActive: isActive, stock: p.stock) : p,
    ).toList();

    state = state.copyWith(products: updatedProducts);
    
    try {
      await _datasource.updateProduct(id, {'is_active': isActive});
    } catch (_) {
      // CORREGIDO: Se añade stock de forma explícita al copyWith de Product
      final revertedProducts = state.products.map<Product>((p) =>
        p.id == id ? p.copyWith(isActive: !isActive, stock: p.stock) : p,
      ).toList();
      state = state.copyWith(products: revertedProducts);
    }
  }

  Future<void> createProduct(Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const ProductFormSaving());
    try {
      final created = await _datasource.createProduct(payload);
      state = state.copyWith(
        products:  <Product>[created, ...state.products],
        total:     state.total + 1,
        formState: const ProductFormSuccess('Producto creado'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: ProductFormError(
          e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const ProductFormSaving());
    try {
      final updated = await _datasource.updateProduct(id, payload);
      final updatedList = state.products.map<Product>((p) => p.id == id ? updated : p).toList();
      state = state.copyWith(
        products: updatedList,
        formState: const ProductFormSuccess('Producto actualizado'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: ProductFormError(
          e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  // Restock — devuelve el nuevo stock
  Future<int?> restock(int id, int quantity) async {
    try {
      final result   = await _datasource.restock(id, quantity);
      final newStock = result['new_stock'] as int;
      // CORREGIDO: Se añade isActive de forma explícita al copyWith de Product
      final updatedList = state.products.map<Product>((p) =>
        p.id == id ? p.copyWith(stock: newStock, isActive: p.isActive) : p,
      ).toList();
      
      state = state.copyWith(products: updatedList);
      return newStock;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _datasource.deleteProduct(id);
      state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList(),
        total:    state.total - 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetFormState() =>
      state = state.copyWith(formState: const ProductFormIdle());
}

final productsAdminProvider =
    StateNotifierProvider<ProductsAdminNotifier, ProductsAdminState>((ref) {
  return ProductsAdminNotifier(ref.watch(productDatasourceProvider));
});