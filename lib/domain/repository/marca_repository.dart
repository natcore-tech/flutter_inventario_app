import '../model/marca.dart';

abstract class MarcaRepository {
    Future<List<Marca>> getMarcas();
    Future<Marca?> getMarcaById(String id);
    Future<Marca> createMarca(Marca marca);
    Future<Marca> updateMarca(Marca marca);
    Future<void> deleteMarca(String id);
}