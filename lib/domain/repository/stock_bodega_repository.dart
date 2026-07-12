import '../model/stock_bodega.dart';

abstract class StockBodegaRepository {
  Future<List<StockBodega>> getAllStock({String? bodegaId, String? productoId});
  Future<StockBodega> updateStock(StockBodega stock);
}