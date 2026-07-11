import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/marca.dart';
import '../../data/repository/marca_repository_impl.dart';

class MarcasAdminNotifier extends AsyncNotifier<List<Marca>> {
    @override
    Future<List<Marca>> build() async => ref.read(marcaRepositoryProvider).getMarcas();

    Future<void> addMarca(Marca marca) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
        await ref.read(marcaRepositoryProvider).createMarca(marca);
        return ref.read(marcaRepositoryProvider).getMarcas();
    });
    }
    
  // (Añadir métodos update y delete siguiendo el mismo patrón de AsyncValue.guard)
}

final marcasAdminProvider = AsyncNotifierProvider<MarcasAdminNotifier, List<Marca>>(() => MarcasAdminNotifier());