import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/bodega.dart';
import '../../domain/model/stock_bodega.dart';
import '../../domain/repository/bodega_repository.dart';
import '../remote/api/bodega_remote_datasource.dart';

class BodegaRepositoryImpl implements BodegaRepository {
  final BodegaRemoteDataSource api;
  BodegaRepositoryImpl(this.api);

  @override Future<List<Bodega>> getBodegas() => api.getBodegas();
  @override Future<List<StockBodega>> getInventarioBodega(String id) => api.getInventarioBodega(id);
  @override Future<Bodega> createBodega(Bodega bodega) => api.createBodega(bodega);
  @override Future<Bodega> updateBodega(Bodega bodega) => api.updateBodega(bodega);
  @override Future<void> deleteBodega(String id) => api.deleteBodega(id);
}

final bodegaRepositoryProvider = Provider<BodegaRepository>((ref) {
  return BodegaRepositoryImpl(ref.watch(bodegaRemoteDataSourceProvider));
});