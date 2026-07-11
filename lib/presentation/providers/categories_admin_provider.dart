import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/category.dart';
import '../../data/repository/category_repository_impl.dart';

class CategoriesAdminNotifier extends AsyncNotifier<List<Categoria>> {
  @override
  Future<List<Categoria>> build() async {
    return _fetchCategories();
  }

  Future<List<Categoria>> _fetchCategories() async {
    final repository = ref.read(categoryRepositoryProvider);
    return await repository.getCategorias();
  }

  // Método para crear una nueva categoría y recargar la lista
  Future<void> addCategory(Categoria categoria) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.createCategoria(categoria);
      return _fetchCategories();
    });
  }

  // Método para actualizar
  Future<void> updateCategory(Categoria categoria) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.updateCategoria(categoria);
      return _fetchCategories();
    });
  }

  // Método para eliminar
  Future<void> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.deleteCategoria(id);
      return _fetchCategories();
    });
  }
}

// El provider que consumirá la UI
final categoriesAdminProvider = AsyncNotifierProvider<CategoriesAdminNotifier, List<Categoria>>(() {
  return CategoriesAdminNotifier();
});