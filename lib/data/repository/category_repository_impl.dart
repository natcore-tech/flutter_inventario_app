import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/category.dart';
import '../../domain/repository/categoria_repository.dart';
import '../remote/api/category_remote_datasource.dart';

class CategoriaRepositoryImpl implements CategoriaRepository {
  final CategoriaRemoteDataSource remoteDataSource;

  CategoriaRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Categoria>> getCategorias() => remoteDataSource.getCategorias();

  @override
  Future<Categoria?> getCategoriaById(String id) => remoteDataSource.getCategoriaById(id);

  @override
  Future<Categoria> createCategoria(Categoria categoria) => remoteDataSource.createCategoria(categoria);

  @override
  Future<Categoria> updateCategoria(Categoria categoria) => remoteDataSource.updateCategoria(categoria);

  @override
  Future<void> deleteCategoria(String id) => remoteDataSource.deleteCategoria(id);
}

final categoryRepositoryProvider = Provider<CategoriaRepository>((ref) {
  final dataSource = ref.watch(categoryRemoteDataSourceProvider);
  return CategoriaRepositoryImpl(dataSource);
});