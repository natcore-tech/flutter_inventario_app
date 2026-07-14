import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/alerta_stock_minimo.dart';
import '../../data/repository/alerta_stock_repository_impl.dart';

class AlertasStockAdminNotifier extends AsyncNotifier<List<AlertaStockMinimo>> {
  @override
  Future<List<AlertaStockMinimo>> build() async => ref.read(alertaStockRepositoryProvider).getAlertas();

  Future<void> addAlerta(AlertaStockMinimo alerta) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(alertaStockRepositoryProvider).createAlerta(alerta);
      return ref.read(alertaStockRepositoryProvider).getAlertas();
    });
  }

  Future<void> updateAlerta(AlertaStockMinimo alerta) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(alertaStockRepositoryProvider).updateAlerta(alerta);
      return ref.read(alertaStockRepositoryProvider).getAlertas();
    });
  }
}

final alertasStockAdminProvider = AsyncNotifierProvider<AlertasStockAdminNotifier, List<AlertaStockMinimo>>(() => AlertasStockAdminNotifier());