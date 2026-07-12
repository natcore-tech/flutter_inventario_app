import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/bodega.dart';
import '../../data/repository/bodega_repository_impl.dart';

class BodegasAdminNotifier extends AsyncNotifier<List<Bodega>> {
  @override
  Future<List<Bodega>> build() async => ref.read(bodegaRepositoryProvider).getBodegas();

  Future<void> addBodega(Bodega bodega) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(bodegaRepositoryProvider).createBodega(bodega);
      return ref.read(bodegaRepositoryProvider).getBodegas();
    });
  }

  Future<void> updateBodega(Bodega bodega) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(bodegaRepositoryProvider).updateBodega(bodega);
      return ref.read(bodegaRepositoryProvider).getBodegas();
    });
  }
}

final bodegasAdminProvider = AsyncNotifierProvider<BodegasAdminNotifier, List<Bodega>>(() => BodegasAdminNotifier());