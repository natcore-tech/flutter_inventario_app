import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/stock_bodega.dart';
import '../../data/repository/stock_bodega_repository_impl.dart';

class StockBodegasAdminNotifier extends AsyncNotifier<List<StockBodega>> {
  @override
  Future<List<StockBodega>> build() async => ref.read(stockBodegaRepositoryProvider).getAllStock();

  Future<void> updateStock(StockBodega stock) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(stockBodegaRepositoryProvider).updateStock(stock);
      return ref.read(stockBodegaRepositoryProvider).getAllStock();
    });
  }
}

final stockBodegasAdminProvider = AsyncNotifierProvider<StockBodegasAdminNotifier, List<StockBodega>>(() => StockBodegasAdminNotifier());