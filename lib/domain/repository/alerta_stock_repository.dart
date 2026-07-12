import '../model/alerta_stock_minimo.dart';

abstract class AlertaStockRepository {
  Future<List<AlertaStockMinimo>> getAlertas();
  Future<AlertaStockMinimo> createAlerta(AlertaStockMinimo alerta);
  Future<AlertaStockMinimo> updateAlerta(AlertaStockMinimo alerta);
}