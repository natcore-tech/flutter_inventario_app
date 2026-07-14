import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/ubicacion_fisica.dart';
import '../../data/repository/ubicacion_fisica_repository_impl.dart';

class UbicacionesAdminNotifier extends AsyncNotifier<List<UbicacionFisica>> {
  @override
  Future<List<UbicacionFisica>> build() async => ref.read(ubicacionFisicaRepositoryProvider).getUbicaciones();

  Future<void> addUbicacion(UbicacionFisica ubicacion) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(ubicacionFisicaRepositoryProvider).createUbicacion(ubicacion);
      return ref.read(ubicacionFisicaRepositoryProvider).getUbicaciones();
    });
  }

  Future<void> updateUbicacion(UbicacionFisica ubicacion) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(ubicacionFisicaRepositoryProvider).updateUbicacion(ubicacion);
      return ref.read(ubicacionFisicaRepositoryProvider).getUbicaciones();
    });
  }
}

final ubicacionesAdminProvider = AsyncNotifierProvider<UbicacionesAdminNotifier, List<UbicacionFisica>>(() => UbicacionesAdminNotifier());