import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/alerta_stock_minimo.dart';
import '../../domain/repository/alerta_stock_repository.dart';
import '../remote/api/alerta_stock_remote_datasource.dart';

class AlertaStockRepositoryImpl implements AlertaStockRepository {
  final AlertaStockRemoteDataSource api;
  AlertaStockRepositoryImpl(this.api);

  @override Future<List<AlertaStockMinimo>> getAlertas() => api.getAlertas();
  @override Future<AlertaStockMinimo> createAlerta(AlertaStockMinimo alerta) => api.createAlerta(alerta);
  @override Future<AlertaStockMinimo> updateAlerta(AlertaStockMinimo alerta) => api.updateAlerta(alerta);
}

final alertaStockRepositoryProvider = Provider<AlertaStockRepository>((ref) {
  return AlertaStockRepositoryImpl(ref.watch(alertaStockRemoteDataSourceProvider));
});