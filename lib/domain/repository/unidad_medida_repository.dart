import '../model/unidad_medida.dart';

abstract class UnidadMedidaRepository {
    Future<List<UnidadMedida>> getUnidadesMedida();
    Future<UnidadMedida?> getUnidadMedidaById(String id);
} // Generalmente las unidades de medida son de solo lectura en la app móvil