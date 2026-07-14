import '../model/ubicacion_fisica.dart';

abstract class UbicacionFisicaRepository {
  Future<List<UbicacionFisica>> getUbicaciones();
  Future<Map<String, dynamic>> verificarDisponibilidad(String id);
  Future<UbicacionFisica> createUbicacion(UbicacionFisica ubicacion);
  Future<UbicacionFisica> updateUbicacion(UbicacionFisica ubicacion);
  Future<void> deleteUbicacion(String id);
}