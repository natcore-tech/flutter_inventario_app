import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/ubicacion_fisica.dart';
import '../../domain/repository/ubicacion_fisica_repository.dart';
import '../remote/api/ubicacion_fisica_remote_datasource.dart';

class UbicacionFisicaRepositoryImpl implements UbicacionFisicaRepository {
  final UbicacionFisicaRemoteDataSource api;
  UbicacionFisicaRepositoryImpl(this.api);

  @override Future<List<UbicacionFisica>> getUbicaciones() => api.getUbicaciones();
  @override Future<Map<String, dynamic>> verificarDisponibilidad(String id) => api.verificarDisponibilidad(id);
  @override Future<UbicacionFisica> createUbicacion(UbicacionFisica ubicacion) => api.createUbicacion(ubicacion);
  @override Future<UbicacionFisica> updateUbicacion(UbicacionFisica ubicacion) => api.updateUbicacion(ubicacion);
  @override Future<void> deleteUbicacion(String id) => api.deleteUbicacion(id);
}

final ubicacionFisicaRepositoryProvider = Provider<UbicacionFisicaRepository>((ref) {
  return UbicacionFisicaRepositoryImpl(ref.watch(ubicacionFisicaRemoteDataSourceProvider));
});