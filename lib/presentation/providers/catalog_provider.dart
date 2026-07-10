import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/marca.dart';
import '../../domain/model/unidad_medida.dart';
import '../../domain/model/promocion.dart';
import '../../data/repository/marca_repository_impl.dart';
import '../../data/repository/unidad_medida_repository_impl.dart';
import '../../data/repository/promocion_repository_impl.dart';

// ── Provider para obtener la lista de Marcas ──
final marcasProvider = FutureProvider<List<Marca>>((ref) async {
  final repository = ref.read(marcaRepositoryProvider);
  return repository.getMarcas();
});

// ── Provider para obtener las Unidades de Medida ──
final unidadesMedidaProvider = FutureProvider<List<UnidadMedida>>((ref) async {
  final repository = ref.read(unidadMedidaRepositoryProvider);
  return repository.getUnidadesMedida();
});

// ── Provider para obtener las Promociones Activas ──
final promocionesActivasProvider = FutureProvider<List<Promocion>>((ref) async {
  final repository = ref.read(promocionRepositoryProvider);
  return repository.getPromocionesActivas();
});