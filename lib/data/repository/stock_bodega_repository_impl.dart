import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/stock_bodega.dart';
import '../../domain/repository/stock_bodega_repository.dart';
import '../remote/api/stock_bodega_remote_datasource.dart';

class StockBodegaRepositoryImpl implements StockBodegaRepository {
  final StockBodegaRemoteDataSource api;
  StockBodegaRepositoryImpl(this.api);

  @override Future<List<StockBodega>> getAllStock({String? bodegaId, String? productoId}) => api.getAllStock(bodegaId: bodegaId, productoId: productoId);
  @override Future<StockBodega> updateStock(StockBodega stock) => api.updateStock(stock);
}

final stockBodegaRepositoryProvider = Provider<StockBodegaRepository>((ref) {
  return StockBodegaRepositoryImpl(ref.watch(stockBodegaRemoteDataSourceProvider));
});