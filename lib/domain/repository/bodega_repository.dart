import '../model/bodega.dart';
import '../model/stock_bodega.dart';

abstract class BodegaRepository {
  Future<List<Bodega>> getBodegas();
  Future<List<StockBodega>> getInventarioBodega(String id);
  Future<Bodega> createBodega(Bodega bodega);
  Future<Bodega> updateBodega(Bodega bodega);
  Future<void> deleteBodega(String id);
}