import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/unidad_medida.dart';
import '../../data/repository/unidad_medida_repository_impl.dart';

class UnidadesMedidaAdminNotifier extends AsyncNotifier<List<UnidadMedida>> {
    @override
    Future<List<UnidadMedida>> build() async {
        return _fetchUnidades();
    }

    Future<List<UnidadMedida>> _fetchUnidades() async {
        final repository = ref.read(unidadMedidaRepositoryProvider);
        return await repository.getUnidadesMedida();
    }

    Future<void> addUnidadMedida(UnidadMedida unidad) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
        // await ref.read(unidadMedidaRepositoryProvider).createUnidadMedida(unidad);
        return _fetchUnidades();
        });
    }

    Future<void> updateUnidadMedida(UnidadMedida unidad) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
        // await ref.read(unidadMedidaRepositoryProvider).updateUnidadMedida(unidad);
        return _fetchUnidades();
        });
    }

    Future<void> deleteUnidadMedida(String id) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
        // await ref.read(unidadMedidaRepositoryProvider).deleteUnidadMedida(id);
        return _fetchUnidades();
        });
    }
}

final unidadesMedidaAdminProvider = AsyncNotifierProvider<UnidadesMedidaAdminNotifier, List<UnidadMedida>>(() {
    return UnidadesMedidaAdminNotifier();
});